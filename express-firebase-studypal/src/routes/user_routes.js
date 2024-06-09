const express = require("express")
const router = express.Router()
const userController = require("../controllers/user_controller")

const { upload } = userController

router.get("/profile/:userId", userController.getProfile)
router.post(
  "/users/:userId/daily-accumulated-time",
  userController.sendDailyAccumulatedTime
)

router.get(
  "/users/:userId/daily-accumulated-time/:date",
  userController.getDailyAccumulatedTime
)

router.put(
  "/users/:email",
  upload.single("image"),
  userController.updateProfile
)
router.get("/users/:email", userController.getUserProfile)

module.exports = router
