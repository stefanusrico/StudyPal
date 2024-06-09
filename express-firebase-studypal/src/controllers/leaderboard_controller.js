const admin = require("firebase-admin")
const db = admin.firestore()
const { getWeekNumber } = require("../utils/utils")

const getAllDailyAccumulatedTimes = async (req, res) => {
  try {
    const dailyTimesCollection = db.collectionGroup("daily")
    const dailyTimesSnapshot = await dailyTimesCollection.get()

    if (dailyTimesSnapshot.empty) {
      return res.status(404).json({ error: "No daily accumulated times found" })
    }

    const dailyTimesPromises = []

    dailyTimesSnapshot.forEach((doc) => {
      const dailyTimeData = doc.data()
      const userRef = doc.ref.parent.parent.parent.parent

      const promise = userRef.get().then((userDoc) => {
        const userId = userDoc.id
        const userData = userDoc.data()
        const fullName = `${userData.first_name} ${userData.last_name}`
        return {
          userId,
          accumulatedTime: dailyTimeData.accumulatedTime,
          startTime: dailyTimeData.startTime,
          finishTime: dailyTimeData.finishTime,
          fullName: fullName,
        }
      })

      dailyTimesPromises.push(promise)
    })

    const dailyTimes = await Promise.all(dailyTimesPromises)
    res.status(200).json(dailyTimes)
  } catch (error) {
    console.error("Error getting all daily accumulated times:", error.message)
    res.status(500).json({ error: "Failed to get daily accumulated times" })
  }
}

const getAllWeeklyAccumulatedTimes = async (req, res) => {
  try {
    const weeklyTimesCollection = db.collectionGroup("weekly")
    const weeklyTimesSnapshot = await weeklyTimesCollection.get()

    if (weeklyTimesSnapshot.empty) {
      return res
        .status(404)
        .json({ error: "No weekly accumulated times found" })
    }

    const weeklyTimesPromises = []

    weeklyTimesSnapshot.forEach((doc) => {
      const weeklyTimeData = doc.data()
      const userRef = doc.ref.parent.parent.parent.parent

      const promise = userRef.get().then((userDoc) => {
        const userId = userDoc.id
        const userData = userDoc.data()
        const fullName = `${userData.first_name} ${userData.last_name}`
        return {
          userId,
          accumulatedTime: weeklyTimeData.accumulatedTime,
          week: weeklyTimeData.week,
          fullName: fullName,
        }
      })

      weeklyTimesPromises.push(promise)
    })

    const resolvedWeeklyTimes = await Promise.all(weeklyTimesPromises)
    res.status(200).json(resolvedWeeklyTimes)
  } catch (error) {
    console.error("Error getting all weekly accumulated times:", error.message)
    res.status(500).json({ error: "Failed to get weekly accumulated times" })
  }
}

const getAllMonthlyAccumulatedTimes = async (req, res) => {
  try {
    const monthlyTimesCollection = db.collectionGroup("monthly")
    const monthlyTimesSnapshot = await monthlyTimesCollection.get()

    if (monthlyTimesSnapshot.empty) {
      return res
        .status(404)
        .json({ error: "No monthly accumulated times found" })
    }

    const monthlyTimesPromises = []

    monthlyTimesSnapshot.forEach((doc) => {
      const monthlyTimeData = doc.data()
      const userRef = doc.ref.parent.parent.parent.parent

      const promise = userRef.get().then((userDoc) => {
        const userId = userDoc.id
        const userData = userDoc.data()
        const fullName = `${userData.first_name} ${userData.last_name}`
        return {
          userId,
          accumulatedTime: monthlyTimeData.accumulatedTime,
          month: monthlyTimeData.month,
          fullName: fullName,
        }
      })

      monthlyTimesPromises.push(promise)
    })

    const monthlyTimes = await Promise.all(monthlyTimesPromises)
    res.status(200).json(monthlyTimes)
  } catch (error) {
    console.error("Error getting all monthly accumulated times:", error.message)
    res.status(500).json({ error: "Failed to get monthly accumulated times" })
  }
}

module.exports = {
  getAllDailyAccumulatedTimes,
  getAllWeeklyAccumulatedTimes,
  getAllMonthlyAccumulatedTimes,
}
