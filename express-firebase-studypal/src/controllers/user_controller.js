const admin = require("firebase-admin")
const db = admin.firestore()
const cloudinary = require("cloudinary").v2
require("dotenv").config()
const multer = require("multer")
const { getWeekNumber } = require("../utils/utils")

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

const sendDailyAccumulatedTime = async (req, res) => {
  try {
    const { userId } = req.params
    const { accumulatedTime, startTime, finishTime } = req.body

    console.log("Received request:", {
      userId,
      accumulatedTime,
      startTime,
      finishTime,
    })

    if (!userId || accumulatedTime === undefined || !finishTime) {
      return res
        .status(400)
        .json({ error: "userId, accumulatedTime, and finishTime are required" })
    }

    const userRef = db.collection("users").doc(userId)
    console.log("userRef:", userRef.path)
    const dailyTimeRef = userRef
      .collection("timer")
      .doc("time")
      .collection("daily")
      .doc(finishTime.split("T")[0])
    console.log("dailyTimeRef:", dailyTimeRef.path)

    const weekNumber = getWeekNumber(new Date(finishTime))
    console.log(weekNumber)
    const monthNumber = new Date(finishTime).toISOString().slice(0, 7)
    console.log(monthNumber)

    const weeklyTimeRef = userRef
      .collection("timer")
      .doc("time")
      .collection("weekly")
      .doc(weekNumber.toString())
    console.log("weeklyTimeRef:", weeklyTimeRef.path)

    const monthlyTimeRef = userRef
      .collection("timer")
      .doc("time")
      .collection("monthly")
      .doc(monthNumber)

    console.log("monthlyTimeRef:", monthlyTimeRef.path)

    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef)
      if (!userDoc.exists) {
        throw new Error("User not found")
      }

      const existingDailyTimeDoc = await transaction.get(dailyTimeRef)
      const existingWeeklyTimeDoc = await transaction.get(weeklyTimeRef)
      const existingMonthlyTimeDoc = await transaction.get(monthlyTimeRef)
      const timeData = {
        accumulatedTime: accumulatedTime,
        finishTime: finishTime,
      }

      if (existingDailyTimeDoc.exists) {
        const existingData = existingDailyTimeDoc.data()
        timeData.startTime = existingData.startTime
      } else if (startTime) {
        timeData.startTime = startTime
      } else {
        timeData.startTime = new Date().toISOString()
      }

      transaction.set(dailyTimeRef, timeData)

      if (existingWeeklyTimeDoc.exists) {
        const existingWeeklyData = existingWeeklyTimeDoc.data()
        timeData.accumulatedTime += existingWeeklyData.accumulatedTime
      }

      if (existingMonthlyTimeDoc.exists) {
        const existingMonthlyData = existingMonthlyTimeDoc.data()
        timeData.accumulatedTime += existingMonthlyData.accumulatedTime
      }

      transaction.set(weeklyTimeRef, {
        accumulatedTime: timeData.accumulatedTime,
        week: weekNumber,
      })

      transaction.set(monthlyTimeRef, {
        accumulatedTime: timeData.accumulatedTime,
        month: monthNumber,
      })
    })

    res
      .status(200)
      .json({ message: "Daily accumulated time sent successfully" })
  } catch (error) {
    console.error("Error sending daily accumulated time:", error.message)
    res.status(500).json({ error: "Failed to send daily accumulated time" })
  }
}

const getDailyAccumulatedTime = async (req, res) => {
  try {
    const { userId, date } = req.params

    if (!userId || !date) {
      return res.status(400).json({ error: "userId and date are required" })
    }

    const userRef = db.collection("users").doc(userId)
    const dailyTimeRef = userRef
      .collection("timer")
      .doc("time")
      .collection("daily")
      .doc(date)

    const dailyTimeDoc = await dailyTimeRef.get()

    if (!dailyTimeDoc.exists) {
      return res.status(404).json({ error: "Daily accumulated time not found" })
    }

    const dailyTimeData = dailyTimeDoc.data()

    res.status(200).json({
      accumulatedTime: dailyTimeData.accumulatedTime,
      startTime: dailyTimeData.startTime,
      finishTime: dailyTimeData.finishTime,
    })
  } catch (error) {
    console.error("Error getting daily accumulated time:", error.message)
    res.status(500).json({ error: "Failed to get daily accumulated time" })
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
  sendDailyAccumulatedTime,
  getDailyAccumulatedTime,
  updateProfile,
  getUserProfile,
  upload,
}
