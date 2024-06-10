const admin = require("firebase-admin")
const db = admin.firestore()

const getGlobalGroup = async (req, res) => {
  try {
    const userId = req.params.userId

    const groupsSnapshot = await db.collection("group-conversations").get()
    const groups = groupsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .filter(
        (group) =>
          group.participantIds && !group.participantIds.includes(userId)
      )

    res.status(200).json(groups)
  } catch (error) {
    console.error("Error getting groups:", error)
    res.status(500).json({ error: "Failed to get groups" })
  }
}

const getGroupData = async (req, res) => {
  try {
    const groupId = req.params.groupId

    const groupDoc = await db
      .collection("group-conversations")
      .doc(groupId)
      .get()

    if (!groupDoc.exists) {
      return res.status(404).json({ error: "Group not found" })
    }

    const groupData = groupDoc.data()

    const participantIds = groupData.participantIds || []
    const userDocs = await Promise.all(
      participantIds.map((userId) => db.collection("users").doc(userId).get())
    )
    const userData = userDocs.map((userDoc) => ({
      id: userDoc.id,
      ...userDoc.data(),
    }))

    const responseData = {
      ...groupData,
      userData,
    }

    res.status(200).json(responseData)
  } catch (error) {
    console.error("Error getting group data:", error)
    res.status(500).json({ error: "Failed to get group data" })
  }
}

const getJoinedGroup = async (req, res) => {
  try {
    const userId = req.params.userId

    const groupsSnapshot = await db.collection("group-conversations").get()
    const groups = groupsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .filter(
        (group) => group.participantIds && group.participantIds.includes(userId)
      )

    res.status(200).json(groups)
  } catch (error) {
    console.error("Error getting joined groups:", error)
    res.status(500).json({ error: "Failed to get joined groups" })
  }
}

const createGroup = async (req, res) => {
  try {
    const { groupName, initiatedBy, description, maxParticipants } = req.body

    const groupRef = db.collection("group-conversations").doc()
    const groupData = {
      groupname: groupName,
      documentId: groupRef.id,
      description: description,
      initiatedAt: admin.firestore.FieldValue.serverTimestamp(),
      initiatedBy: initiatedBy,
      lastMessage: null,
      lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      participantIds: [initiatedBy],
      maxParticipants: maxParticipants,
    }

    await groupRef.set(groupData)

    const userSnapshot = await db
      .collection("users")
      .where("email", "==", initiatedBy)
      .limit(1)
      .get()

    if (!userSnapshot.empty) {
      const userData = userSnapshot.docs[0].data()
      const participantData = {
        userId: userData.email,
        imageUrl: userData.imageUrl || "",
        email: userData.email,
        name: userData.first_name + " " + userData.last_name,
      }

      const participantRef = groupRef
        .collection("participants")
        .doc(initiatedBy)
      await participantRef.set(participantData)
    }

    res
      .status(200)
      .json({ groupId: groupRef.id, message: "Group created successfully" })
  } catch (error) {
    console.error("Error creating group:", error)
    res.status(500).json({ error: "Failed to create group" })
  }
}

const joinGroup = async (req, res) => {
  try {
    const { groupId } = req.params
    const { userId } = req.body

    // Periksa apakah grup dengan groupId yang diberikan ada
    const groupRef = db.collection("group-conversations").doc(groupId)
    const groupDoc = await groupRef.get()

    if (!groupDoc.exists) {
      return res.status(404).json({ error: "Group not found" })
    }

    const groupData = groupDoc.data()

    const participantSnapshot = await groupRef
      .collection("participants")
      .where("userId", "==", userId)
      .limit(1)
      .get()

    if (!participantSnapshot.empty) {
      return res.status(400).json({ error: "User already joined the group" })
    }

    const currentParticipantIds = groupData.participantIds || []
    const maxParticipants = groupData.maxParticipants || 0
    if (currentParticipantIds.length >= maxParticipants) {
      return res
        .status(400)
        .json({ error: "Maximum number of participants reached" })
    }

    const userSnapshot = await db
      .collection("users")
      .where("email", "==", userId)
      .limit(1)
      .get()

    if (userSnapshot.empty) {
      return res.status(404).json({ error: "User not found" })
    }

    const userData = userSnapshot.docs[0].data()
    const participantData = {
      userId: userData.email,
      imageUrl: userData.imageUrl || "",
      email: userData.email,
      name: userData.first_name + " " + userData.last_name,
    }

    const participantRef = groupRef.collection("participants").doc(userId)
    await participantRef.set(participantData)

    await groupRef.update({
      participantIds: admin.firestore.FieldValue.arrayUnion(userId),
    })

    res.status(200).json({ message: "User joined the group successfully" })
  } catch (error) {
    console.error("Error joining group:", error)
    res.status(500).json({ error: "Failed to join group" })
  }
}

const groupTotalTime = async (req, res) => {
  try {
    const groupId = req.params.groupId

    const groupDoc = await db
      .collection("group-conversations")
      .doc(groupId)
      .get()
    if (!groupDoc.exists) {
      return res.status(404).json({ error: "Group not found" })
    }
    const participantIds = groupDoc.data().participantIds

    let totalAccumulatedTime = 0

    for (const participantId of participantIds) {
      const userRef = db.collection("users").doc(participantId)
      const dailyTimesCollection = userRef
        .collection("timer")
        .doc("time")
        .collection("daily")

      console.log("Daily times collection path:", dailyTimesCollection.path) // Cetak path referensi dokumen

      const dailyTimesSnapshot = await dailyTimesCollection.get()

      let participantAccumulatedTime = 0
      dailyTimesSnapshot.forEach((doc) => {
        const dailyTimeData = doc.data()
        if (dailyTimeData.accumulatedTime) {
          participantAccumulatedTime += dailyTimeData.accumulatedTime
        }
      })

      totalAccumulatedTime += participantAccumulatedTime
    }

    res.status(200).json({ totalAccumulatedTime })
  } catch (error) {
    console.error("Error getting total daily accumulated time:", error.message)
    res
      .status(500)
      .json({ error: "Failed to get total daily accumulated time" })
  }
}

module.exports = {
  getGlobalGroup,
  getGroupData,
  getJoinedGroup,
  groupTotalTime,
  createGroup,
  joinGroup,
}
