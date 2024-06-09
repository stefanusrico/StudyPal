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

module.exports = {
  isValidEmail,
  isEmailRegistered,
}
