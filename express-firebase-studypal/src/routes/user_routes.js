const express = require("express")
const router = express.Router()
const userController = require("../controllers/user_controller")

const { upload } = userController

router.get("/profile/:userId", userController.getProfile)
router.post(
  "/users/:userId/send-accumulated-time",
  userController.sendAccumulateTime
)
router.get("/users/:userId/accumulated-time", userController.getAccumulatedTime)
router.put(
  "/users/:email",
  upload.single("image"),
  userController.updateProfile
)
router.get("/users/:email", userController.getUserProfile)

module.exports = router
