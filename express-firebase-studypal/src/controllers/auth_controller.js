const bcrypt = require("bcrypt")
const jwt = require("jsonwebtoken")
const admin = require("firebase-admin")
const db = admin.firestore()
require("dotenv").config()
const { isValidEmail, isEmailRegistered } = require("../utils/utils")

const secretKey = "adit"

const register = async (req, res) => {
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
      status: "offline",
      image: "",
    }
    const usersDb = db.collection("users")
    const response = await usersDb.doc(id).set(userJson)
    res
      .status(200)
      .json({ statusCode: "200", message: "Registered Successfully" })
  } catch (error) {
    res.status(500).json({ statusCode: "500", message: error.message })
  }
}

const login = async (req, res) => {
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

    const userData = userQuerySnapshot.docs[0].data()

    const passwordMatch = await bcrypt.compare(password, userData.password)
    if (!passwordMatch) {
      return res.status(401).json({ error: "Invalid email or password" })
    }

    await db
      .collection("users")
      .doc(userData.email)
      .update({ status: "online" })

    const token = jwt.sign({ email: userData.email }, secretKey, {
      expiresIn: "24h",
    })
    console.log(userData.email)
    console.log(token)
    res.json({ message: "Login successful", token })
  } catch (error) {
    console.error("Error during login:", error)
    res.status(500).json({ error: "Failed to login" })
  }
}

const logout = async (req, res) => {
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
}

module.exports = {
  register,
  login,
  logout,
}
