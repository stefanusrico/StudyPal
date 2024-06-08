const express = require("express")
const http = require("http").createServer(app)
const io = require("socket.io")(http)
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

app.post("/logout", async (req, res) => {
  try {
    const { token } = req.body

    jwt.verify(token, secretKey, async (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: "Invalid token" })
      }

      const userEmail = decoded.email

      await db.collection("users").doc(userEmail).update({ status: "offline" })

      res.status(200).json({ message: "Logout successful" })
    })
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
    const { accumulatedTime, startTime, finishTime } = req.body

    if (!userId || accumulatedTime === undefined || !finishTime) {
      return res
        .status(400)
        .json({ error: "userId, accumulatedTime, and finishTime are required" })
    }

    const userRef = db.collection("users").doc(userId)
    const timeRef = userRef.collection("timer").doc("time")

    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef)
      if (!userDoc.exists) {
        throw new Error("User not found")
      }

      const existingTimeDoc = await transaction.get(timeRef)
      const timeData = {
        accumulatedTime: accumulatedTime,
        finishTime: finishTime,
      }

      if (existingTimeDoc.exists) {
        const existingData = existingTimeDoc.data()
        timeData.startTime = existingData.startTime
      } else if (startTime) {
        timeData.startTime = startTime
      } else {
        timeData.startTime = new Date().toISOString()
      }

      transaction.set(timeRef, timeData)
    })

    res.status(200).json({ message: "Accumulated time sent successfully" })
  } catch (error) {
    console.error("Error sending accumulated time:", error.message)
    res.status(500).json({ error: "Failed to send accumulated time" })
  }
})

app.get("/users/:userId/accumulated-time", async (req, res) => {
  try {
    const { userId } = req.params

    const userRef = db.collection("users").doc(userId)
    const timeRef = userRef.collection("timer").doc("time")

    const timeDoc = await timeRef.get()

    if (!timeDoc.exists) {
      return res.status(404).json({ error: "Accumulated time not found" })
    }

    const timeData = timeDoc.data()

    res.status(200).json({
      accumulatedTime: timeData.accumulatedTime,
      startTime: timeData.startTime,
      finishTime: timeData.finishTime,
    })
  } catch (error) {
    console.error("Error getting accumulated time:", error.message)
    res.status(500).json({ error: "Failed to get accumulated time" })
  }
})

app.get("/messages", async (req, res) => {
  try {
    const snapshot = await db
      .collection("messages")
      .orderBy("timestamp", "desc")
      .get()
    const messages = snapshot.docs.map((doc) => doc.data())
    res.json(messages)
  } catch (error) {
    console.error("Error fetching messages from Firestore:", error)
    res.status(500).json({ error: "Internal server error" })
  }
})

app.get("/messages/:groupId", async (req, res) => {
  try {
    const { groupId } = req.params
    const { email } = req.query

    const messagesSnapshot = await db
      .collection("group-conversations")
      .doc(groupId)
      .collection("messages")
      .orderBy("timestamp", "desc")
      .get()

    const messages = []

    for (const doc of messagesSnapshot.docs) {
      const messageData = doc.data()
      const senderId = messageData.senderId

      const userSnapshot = await db
        .collection("users")
        .where("email", "==", senderId)
        .limit(1)
        .get()

      if (!userSnapshot.empty) {
        const userData = userSnapshot.docs[0].data()
        const firstName = userData.first_name
        const lastName = userData.last_name

        messageData.fullName = firstName + " " + lastName
      }

      messages.push(messageData)
    }

    res.json(messages)
  } catch (error) {
    console.error("Error fetching messages:", error)
    res.status(500).json({ error: "Internal server error" })
  }
})

app.get("/groups/:userId", async (req, res) => {
  try {
    const userId = req.params.userId

    const groupsSnapshot = await db.collection("group-conversations").get()
    const groups = groupsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .filter(
        (group) =>
          group.participantIds && !group.participantIds.includes(userId)
      )

    res.status(200).json(groups)
  } catch (error) {
    console.error("Error getting groups:", error)
    res.status(500).json({ error: "Failed to get groups" })
  }
})

app.get("/group/:groupId", async (req, res) => {
  try {
    const groupId = req.params.groupId

    const groupDoc = await db
      .collection("group-conversations")
      .doc(groupId)
      .get()

    if (!groupDoc.exists) {
      return res.status(404).json({ error: "Group not found" })
    }

    const groupData = groupDoc.data()

    const participantIds = groupData.participantIds || []
    const userDocs = await Promise.all(
      participantIds.map((userId) => db.collection("users").doc(userId).get())
    )
    const userData = userDocs.map((userDoc) => ({
      id: userDoc.id,
      ...userDoc.data(),
    }))

    const responseData = {
      ...groupData,
      userData,
    }

    res.status(200).json(responseData)
  } catch (error) {
    console.error("Error getting group data:", error)
    res.status(500).json({ error: "Failed to get group data" })
  }
})

app.get("/groups/joined/:userId", async (req, res) => {
  try {
    const userId = req.params.userId

    const groupsSnapshot = await db.collection("group-conversations").get()
    const groups = groupsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .filter(
        (group) => group.participantIds && group.participantIds.includes(userId)
      )

    res.status(200).json(groups)
  } catch (error) {
    console.error("Error getting joined groups:", error)
    res.status(500).json({ error: "Failed to get joined groups" })
  }
})

app.post("/create-group", async (req, res) => {
  try {
    const { groupName, initiatedBy, description, maxParticipants } = req.body

    const groupRef = db.collection("group-conversations").doc()
    const groupData = {
      groupname: groupName,
      documentId: groupRef.id,
      description: description,
      initiatedAt: admin.firestore.FieldValue.serverTimestamp(),
      initiatedBy: initiatedBy,
      lastMessage: null,
      lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      participantIds: [initiatedBy],
      maxParticipants: maxParticipants,
    }

    await groupRef.set(groupData)

    const userSnapshot = await db
      .collection("users")
      .where("email", "==", initiatedBy)
      .limit(1)
      .get()

    if (!userSnapshot.empty) {
      const userData = userSnapshot.docs[0].data()
      const participantData = {
        userId: userData.email,
        imageUrl: userData.imageUrl || "",
        email: userData.email,
        name: userData.first_name + " " + userData.last_name,
      }

      const participantRef = groupRef
        .collection("participants")
        .doc(initiatedBy)
      await participantRef.set(participantData)
    }

    res
      .status(200)
      .json({ groupId: groupRef.id, message: "Group created successfully" })
  } catch (error) {
    console.error("Error creating group:", error)
    res.status(500).json({ error: "Failed to create group" })
  }
})

// Endpoint untuk bergabung dengan grup
app.post("/groups/:groupId/join", async (req, res) => {
  try {
    const { groupId } = req.params
    const { userId } = req.body

    // Periksa apakah grup dengan groupId yang diberikan ada
    const groupRef = db.collection("group-conversations").doc(groupId)
    const groupDoc = await groupRef.get()

    if (!groupDoc.exists) {
      return res.status(404).json({ error: "Group not found" })
    }

    const groupData = groupDoc.data()

    const participantSnapshot = await groupRef
      .collection("participants")
      .where("userId", "==", userId)
      .limit(1)
      .get()

    if (!participantSnapshot.empty) {
      return res.status(400).json({ error: "User already joined the group" })
    }

    const currentParticipantIds = groupData.participantIds || []
    const maxParticipants = groupData.maxParticipants || 0
    if (currentParticipantIds.length >= maxParticipants) {
      return res
        .status(400)
        .json({ error: "Maximum number of participants reached" })
    }

    const userSnapshot = await db
      .collection("users")
      .where("email", "==", userId)
      .limit(1)
      .get()

    if (userSnapshot.empty) {
      return res.status(404).json({ error: "User not found" })
    }

    const userData = userSnapshot.docs[0].data()
    const participantData = {
      userId: userData.email,
      imageUrl: userData.imageUrl || "",
      email: userData.email,
      name: userData.first_name + " " + userData.last_name,
    }

    const participantRef = groupRef.collection("participants").doc(userId)
    await participantRef.set(participantData)

    await groupRef.update({
      participantIds: admin.firestore.FieldValue.arrayUnion(userId),
    })

    res.status(200).json({ message: "User joined the group successfully" })
  } catch (error) {
    console.error("Error joining group:", error)
    res.status(500).json({ error: "Failed to join group" })
  }
})

io.on("connection", (socket) => {
  console.log("New client connected")

  socket.on("message", async (data) => {
    try {
      const { senderId, text, groupId } = JSON.parse(data)

      const groupRef = db.collection("group-conversations").doc(groupId)
      const messageData = {
        message: text,
        senderId: senderId,
        recipientId: null,
        status: "sent",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      }

      await db.runTransaction(async (transaction) => {
        const groupDoc = await transaction.get(groupRef)
        if (!groupDoc.exists) {
          throw new Error("Group not found")
        }

        const lastMessage = {
          message: text,
          senderId: senderId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        }

        transaction.update(groupRef, {
          lastMessage: lastMessage,
          lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        })

        transaction.set(groupRef.collection("messages").doc(), messageData)
      })

      console.log("Received Message: ", data)
      io.emit("message", { groupId, ...data })
    } catch (error) {
      console.error("Error saving message to Firestore:", error)
    }
  })

  socket.on("disconnect", () => {
    console.log("Client disconnected")
  })
})

app.put("/users/:email", async (req, res) => {
  try {
    const { email } = req.params
    const { first_name, last_name, birth_date } = req.body

    const userRef = db.collection("users").doc(email)

    const userDoc = await userRef.get()

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    await userRef.update({
      first_name,
      last_name,
      birth_date,
    })

    res.status(200).json({ message: "Profile updated successfully" })
  } catch (error) {
    console.error("Error updating profile:", error)
    res.status(500).json({ error: "Failed to update profile" })
  }
})

app.get("/users/:email", async (req, res) => {
  try {
    const { email } = req.params

    const userRef = db.collection("users").doc(email)
    const userDoc = await userRef.get()

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    const { first_name, last_name, birth_date } = userDoc.data()
    const fullName = `${first_name} ${last_name}`

    res.status(200).json({ fullName, birth_date })
  } catch (error) {
    console.error("Error fetching user data:", error)
    res.status(500).json({ error: "Failed to fetch user data" })
  }
})

app.get("/test", (req, res) => {
  res.send("Hello World!")
})

const PORT = 4000
http.listen(PORT, "0.0.0.0", () => {
  console.log(`Express API running in PORT: ${PORT}`)
})
