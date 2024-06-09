require("dotenv").config()
const admin = require("firebase-admin")

const serviceAccount = require("../../firebase_credentials.json")

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL,
})

const db = admin.firestore()

module.exports = { db }
