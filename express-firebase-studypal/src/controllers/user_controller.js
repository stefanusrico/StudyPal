const admin = require("firebase-admin")
const db = admin.firestore()
const cloudinary = require("cloudinary").v2
require("dotenv").config()
const multer = require("multer")

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/")
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname)
  },
})

const upload = multer({ storage: storage })

cloudinary.config({
  cloud_name: "dhnvjgrre",
  api_key: "351778397476311",
  api_secret: "qCXKNVJKxkzuSIweuQMkP_g5zXI",
})

const getProfile = async (req, res) => {
  try {
    const { userId } = req.params

    const userData = await db.collection("users").doc(userId).get()

    if (!userData.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    const { first_name, last_name, email, birth_date, image } = userData.data()

    const fullName = `${first_name} ${last_name}`

    res.status(200).json({ fullName, email, birth_date, image })
  } catch (error) {
    console.error("Error fetching user data:", error)
    res.status(500).json({ error: "Failed to fetch user data" })
  }
}

const sendAccumulateTime = async (req, res) => {
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
}

const getAccumulatedTime = async (req, res) => {
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
}

const updateProfile = async (req, res) => {
  try {
    const { email } = req.params
    const { first_name, last_name, birth_date } = req.body
    const imageFile = req.file

    const updateData = {}

    if (first_name) {
      updateData.first_name = first_name
    }

    if (last_name) {
      updateData.last_name = last_name
    }

    if (birth_date) {
      updateData.birth_date = birth_date
    }

    if (imageFile) {
      const result = await cloudinary.uploader.upload(imageFile.path)
      updateData.image = result.secure_url
    }

    const userRef = db.collection("users").doc(email)
    const userDoc = await userRef.get()

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    await userRef.update(updateData)

    res.status(200).json({ message: "Profile updated successfully" })
  } catch (error) {
    console.error("Error updating profile:", error)
    console.error("Error updating profile:", error.message)
    console.error("Error stack trace:", error.stack)
    console.error("Request body:", req.body)
    console.error("Request file:", req.file)
    res.status(500).json({ error: "Failed to update profile" })
  }
}

const getUserProfile = async (req, res) => {
  try {
    const { email } = req.params

    const userRef = db.collection("users").doc(email)
    const userDoc = await userRef.get()

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" })
    }

    const { first_name, last_name, birth_date, image } = userDoc.data()

    res.status(200).json({ first_name, last_name, birth_date, image })
  } catch (error) {
    console.error("Error fetching user data:", error)
    res.status(500).json({ error: "Failed to fetch user data" })
  }
}

module.exports = {
  getProfile,
  sendAccumulateTime,
  getAccumulatedTime,
  updateProfile,
  getUserProfile,
  upload,
}
