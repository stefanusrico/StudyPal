const express = require("express")
const router = express.Router()
const groupController = require("../controllers/group_controller")

router.get("/groups/:userId", groupController.getGlobalGroup)
router.get("/group/:groupId", groupController.getGroupData)
router.get("/groups/joined/:userId", groupController.getJoinedGroup)
router.post("/create-group", groupController.createGroup)
router.post("/groups/:groupId/join", groupController.joinGroup)

module.exports = router
