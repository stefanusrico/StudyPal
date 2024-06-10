const express = require("express")
const router = express.Router()
const leaderboardController = require("../controllers/leaderboard_controller")

router.get(
  "/daily-accumulated-times",
  leaderboardController.getAllDailyAccumulatedTimes
)

router.get(
  "/weekly-accumulated-times",
  leaderboardController.getAllWeeklyAccumulatedTimes
)

router.get(
  "/monthly-accumulated-times",
  leaderboardController.getAllMonthlyAccumulatedTimes
)

module.exports = router
