const express = require("express")
const cors = require("cors")
const admin = require("firebase-admin")
const bcrypt = require("bcrypt")
const scrypt = require("scrypt")
const serviceAccount = require("C:\\Users\\ACER\\Desktop\\express-firebase-studypal\\firebase_credentials.json")
const { initializeApp } = require("firebase/app")
const {
  getFirestore,
  collection,
  addDoc,
  getDoc,
  doc,
} = require("firebase/firestore/lite")
const {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
} = require("firebase/auth")
const cookieParser = require("cookie-parser")
const { UserRecord } = require("firebase-admin/auth")

const app = express()
app.use(express.json())
app.use(cors())
app.use(cookieParser())

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
})

const firebaseConfig = {
  apiKey: "AIzaSyDcA_ZWNAqONwPYr4KcMN4BxWTkFVvgqJI",
  authDomain: "studypal-4bfd8.firebaseapp.com",
  databaseURL:
    "https://studypal-4bfd8-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "studypal-4bfd8",
  storageBucket: "studypal-4bfd8.appspot.com",
  messagingSenderId: "117521201224",
  appId: "1:117521201224:web:a3561bdda2d6b89a95407d",
  measurementId: "G-1ER1KD5MKL",
}

const firebaseApp = initializeApp(firebaseConfig)
const db = getFirestore(firebaseApp)
const UserCollection = collection(db, "Users")
const auth = getAuth(firebaseApp)

const authAdmin = admin.auth()

async function isAuthenticated(req, res, next) {
  const token = req.cookies.token

  if (!token) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  try {
    const decodedToken = await authAdmin.verifyIdToken(token)
    req.user = decodedToken
    console.log(decodedToken)
    next()
  } catch (error) {
    console.error("Error verifying token: ", error)
    return res.status(403).json({ message: "Forbidden" })
  }
}

app.get("/secure-route", isAuthenticated, (req, res) => {
  res.send("Protected Route Accessed. User ID: " + req.user.uid)
})

app.get("/check-token", isAuthenticated, async (req, res) => {
  try {
    const authUser = await authAdmin.getUser(req.user.uid)
    console.log(authUser)
    const userData = {
      uid: authUser.uid,
      email: authUser.email,
      displayName: authUser.displayName,
      creationTime: authUser.metadata.creationTime,
      lastSignInTime: authUser.metadata.lastSignInTime,
      lastRefreshTime: authUser.metadata.lastRefreshTime,
      tokenValidAfterTime: authUser.tokensValidAfterTime,
    }

    res.send({
      message: "Token is valid",
      user: userData,
    })
  } catch (error) {
    console.error("Error fetching user data:", error)
    res.status(500).send({ error: "Error fetching user data" })
  }
})

const hash_config = {
  algorithm: "SCRYPT",
  base64_signer_key:
    "HWiJ3iFGE6kew4Kf/G431YCbEXb8r6OrUCVc5A9tBXy4zhYBQDrrOOHs6Ph6vgQFU+QLUX0kqrxZrIV9vkCfNw==",
  base64_salt_separator: "Bw==",
  rounds: 8,
  mem_cost: 14,
}

app.post("/register", async (req, res) => {
  try {
    const { email, password, first_name, last_name, gender, birth_date } =
      req.body

    const userRecord = await authAdmin.createUser({
      email: email,
      password: password,
    })

    console.log(userRecord)

    const uid = userRecord.uid

    // Tambahkan pengguna ke Firestore
    await addDoc(UserCollection, {
      uid: uid,
      email: email,
      first_name: first_name,
      last_name: last_name,
      gender: gender,
      birth_date: birth_date,
    })

    res.send({
      msg: "User registered successfully",
      uid: uid,
    })
  } catch (error) {
    console.error("Error registering user: ", error)
    res.status(500).send({ error: "Error registering user" })
  }
})

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body

    const userRecord = await admin.auth().getUserByEmail(email)

    // Jika kredensial valid, kirimkan token

    const token = await admin.auth().createCustomToken(userRecord.uid)

    res.cookie("token", token, { httpOnly: true })
    res.send({
      msg: "Login successful",
      uid: userRecord.uid,
      token: token,
    })
  } catch (error) {
    console.error("Error logging in: ", error)
    res.status(500).send({ error: "Error logging in" })
  }
})

app.post("/logout", async (req, res) => {
  try {
    res.clearCookie("token")
    await signOut(auth)
    res.send({ msg: "Logout successful" })
  } catch (error) {
    console.error("Error logging out: ", error)
    res.status(500).send({ error: "Error logging out" })
  }
})

app.get("/test", (req, res) => {
  res.send("Hello World!")
})

const PORT = 4000
app.listen(PORT, "0.0.0.0", () => {
  console.log("Express API running in PORT: " + PORT)
})
