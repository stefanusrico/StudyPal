const express = require("express")
const http = require("http")
const app = express()
const server = http.createServer(app)
const io = require("socket.io")(server)
const { db } = require("./config/firebase")

const multer = require("multer")
require("dotenv").config()

const authMiddleware = require("./middleware/auth_middleware")
const authRoutes = require("./routes/auth_routes")
const userRoutes = require("./routes/user_routes")
const groupRoutes = require("./routes/group_routes")
const messageRoutes = require("./routes/message_routes")
const leaderboardRoutes = require("./routes/leaderboard_routes")
const socketEvents = require("./socket/socket")

const bodyParser = require("body-parser")

app.use(express.json())
app.use(authRoutes)
app.use(authMiddleware)
app.use(bodyParser.json())
app.use(userRoutes)
app.use(groupRoutes)
app.use(messageRoutes)
app.use(leaderboardRoutes)
socketEvents(io)

const PORT = process.env.PORT || 4000
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
