const { db } = require("../config/firebase")
const admin = require("firebase-admin")

module.exports = (io) => {
  io.on("connection", (socket) => {
    console.log("New client connected")

    socket.on("message", async (data) => {
      try {
        const { senderId, text, groupId } = JSON.parse(data)

        const groupRef = db.collection("group-conversations").doc(groupId)
        const messageData = {
          message: text,
          senderId: senderId,
          recipientId: null,
          status: "sent",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        }

        await db.runTransaction(async (transaction) => {
          const groupDoc = await transaction.get(groupRef)
          if (!groupDoc.exists) {
            throw new Error("Group not found")
          }

          const lastMessage = {
            message: text,
            senderId: senderId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          }

          transaction.update(groupRef, {
            lastMessage: lastMessage,
            lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          })

          transaction.set(groupRef.collection("messages").doc(), messageData)
        })

        console.log("Received Message: ", data)
        io.emit("message", { groupId, ...data })
      } catch (error) {
        console.error("Error saving message to Firestore:", error)
      }
    })

    socket.on("disconnect", () => {
      console.log("Client disconnected")
    })
  })
}
