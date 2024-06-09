const admin = require("firebase-admin")
const db = admin.firestore()
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

async function isEmailRegistered(email) {
  const user = await db.collection("users").where("email", "==", email).get()
  return !user.empty
}

function getWeekNumber(date) {
  const firstDayOfYear = new Date(date.getFullYear(), 0, 1)
  const pastDaysOfYear = (date - firstDayOfYear) / 86400000
  return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7)
}

module.exports = {
  isValidEmail,
  isEmailRegistered,
  getWeekNumber
}
