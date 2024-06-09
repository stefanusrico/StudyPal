const admin = require("firebase-admin")
const db = admin.firestore()

const getMessages = async (req, res) => {
  try {
    const { groupId } = req.params
    const { email } = req.query

    const messagesSnapshot = await db
      .collection("group-conversations")
      .doc(groupId)
      .collection("messages")
      .orderBy("timestamp", "desc")
      .get()

    const messages = []

    for (const doc of messagesSnapshot.docs) {
      const messageData = doc.data()
      const senderId = messageData.senderId

      const userSnapshot = await db
        .collection("users")
        .where("email", "==", senderId)
        .limit(1)
        .get()

      if (!userSnapshot.empty) {
        const userData = userSnapshot.docs[0].data()
        const firstName = userData.first_name
        const lastName = userData.last_name

        messageData.fullName = firstName + " " + lastName
      }

      messages.push(messageData)
    }

    res.json(messages)
  } catch (error) {
    console.error("Error fetching messages:", error)
    res.status(500).json({ error: "Internal server error" })
  }
}

module.exports = {
  getMessages,
}
