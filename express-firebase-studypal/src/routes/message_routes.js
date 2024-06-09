const express = require("express")
const router = express.Router()
const messageController = require("../controllers/message_controller")

router.get("/messages/:groupId", messageController.getMessages)

module.exports = router
