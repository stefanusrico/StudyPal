const express = require("express")
const cors = require("cors")
const admin = require("firebase-admin")
const bcrypt = require("bcrypt")
const jwt = require("jsonwebtoken")
const serviceAccount = require("C:\\Users\\ACER\\Desktop\\express-firebase-studypal\\firebase_credentials.json")
const { initializeApp } = require("firebase/app")
const cookieParser = require("cookie-parser")

const app = express()
app.use(express.json())
app.use(cors())
app.use(cookieParser())

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
})

const db = admin.firestore()
const revokedTokens = new Set()
const secretKey = "adit"

function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Fungsi untuk memeriksa apakah email sudah terdaftar
async function isEmailRegistered(email) {
  const user = await db.collection("users").where("email", "==", email).get()
  return !user.empty
}

app.post("/register", async (req, res) => {
  try {
    if (!isValidEmail(req.body.email)) {
      return res
        .status(400)
        .json({ statusCode: "400", message: "Invalid email format" })
    }

    if (await isEmailRegistered(req.body.email)) {
      return res
        .status(400)
        .json({ statusCode: "400", message: "Email is already registered" })
    }

    const encrypted_password = await bcrypt.hash(req.body.password, 10)
    console.log(req.body)
    const id = req.body.email
    const userJson = {
      email: req.body.email,
      password: encrypted_password,
      first_name: req.body.first_name,
      last_name: req.body.last_name,
      gender: req.body.gender,
      birth_date: req.body.birth_date,
    }
    const usersDb = db.collection("users")
    const response = await usersDb.doc(id).set(userJson)
    res
      .status(200)
      .json({ statusCode: "200", message: "Registered Successfully" })
  } catch (error) {
    res.status(500).json({ statusCode: "500", message: error.message })
  }
})

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body

    const userQuerySnapshot = await db
      .collection("users")
      .where("email", "==", email)
      .limit(1)
      .get()
    if (userQuerySnapshot.empty) {
      return res.status(401).json({ error: "Invalid email or password" })
    }

    // Ambil data user
    const userData = userQuerySnapshot.docs[0].data()

    // Periksa apakah password yang diberikan cocok dengan yang tersimpan di database
    const passwordMatch = await bcrypt.compare(password, userData.password)
    if (!passwordMatch) {
      return res.status(401).json({ error: "Invalid email or password" })
    }

    const token = jwt.sign({ email: userData.email }, secretKey, {
      expiresIn: "24h",
    })
    console.log(userData.email)
    // Login berhasil, kirim JWT sebagai respons
    console.log(token)
    res.json({ message: "Login successful", token })
  } catch (error) {
    console.error("Error during login:", error)
    res.status(500).json({ error: "Failed to login" })
  }
})

app.post("/check-token", async (req, res) => {
  try {
    // Ambil token dari body request
    const token = req.body.token

    if (!token) {
      return res.status(400).json({ error: "Token is missing" })
    }

    // Verifikasi token
    jwt.verify(token, secretKey, async (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: "Invalid token" })
      }

      // Dapatkan data pengguna dari email yang terkandung dalam token
      const userEmail = decoded.email
      const userQuerySnapshot = await db
        .collection("users")
        .where("email", "==", userEmail)
        .limit(1)
        .get()

      if (userQuerySnapshot.empty) {
        return res.status(404).json({ error: "User not found" })
      }

      // Ambil data pengguna dari snapshot dan kirimkan sebagai respons
      const userData = userQuerySnapshot.docs[0].data()
      res.json(userData)
    })
  } catch (error) {
    console.error("Error during token check:", error)
    res.status(500).json({ error: "Failed to check token" })
  }
})

app.post("/logout", (req, res) => {
  try {
    const { token } = req.body

    // Tambahkan token ke dalam daftar token yang sudah logout
    revokedTokens.add(token)
    console.log(revokedTokens)

    // Berikan respons yang sesuai
    res.status(200).json({ message: "Logout successful" })
  } catch (error) {
    console.error("Error during logout:", error)
    res.status(500).json({ error: "Failed to logout" })
  }
})

app.use((req, res, next) => {
  const authorizationHeader = req.headers.authorization

  if (!authorizationHeader || !authorizationHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized" })
  }

  const token = authorizationHeader.split(" ")[1]

  // Periksa apakah token ada dalam daftar token yang sudah logout
  if (revokedTokens.has(token)) {
    return res.status(401).json({ error: "Token revoked" })
  }

  next()
})

app.get("/profile/:userId", async (req, res) => {
  try {
    const { userId } = req.params

    const userData = await db.collection("users").doc(userId).get()

    if (!userData.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    const { first_name, last_name, email, birth_date } = userData.data()

    const fullName = `${first_name} ${last_name}`

    res.status(200).json({ fullName, email, birth_date })
  } catch (error) {
    console.error("Error fetching user data:", error)
    res.status(500).json({ error: "Failed to fetch user data" })
  }
})

app.post("/users/:userId/send-accumulated-time", async (req, res) => {
  try {
    const { userId } = req.params
    const { accumulatedTime } = req.body

    if (!userId || accumulatedTime === undefined) {
      return res
        .status(400)
        .json({ error: "userId and accumulatedTime are required" })
    }

    const userRef = db.collection("users").doc(userId)
    const timeRef = userRef.collection("time").doc("accumulatedTime")

    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef)
      if (!userDoc.exists) {
        throw new Error("User not found")
      }

      const timeDoc = await transaction.get(timeRef)
      let newAccumulatedTime = accumulatedTime

      if (timeDoc.exists) {
        const currentData = timeDoc.data()
        newAccumulatedTime += currentData.accumulatedTime || 0
      }

      transaction.set(timeRef, { accumulatedTime: newAccumulatedTime })
    })

    res.status(200).json({ message: "Accumulated time sent successfully" })
  } catch (error) {
    console.error("Error sending accumulated time:", error.message)
    res.status(500).json({ error: "Failed to send accumulated time" })
  }
})

app.get("/test", (req, res) => {
  res.send("Hello World!")
})

const PORT = 4000
app.listen(PORT, "0.0.0.0", () => {
  console.log("Express API running in PORT: " + PORT)
})
