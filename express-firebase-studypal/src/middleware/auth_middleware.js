const revokedTokens = new Set()

const authMiddleware = (req, res, next) => {
  const authorizationHeader = req.headers.authorization

  if (!authorizationHeader || !authorizationHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized" })
  }

  const token = authorizationHeader.split(" ")[1]

  if (revokedTokens.has(token)) {
    return res.status(401).json({ error: "Token revoked" })
  }

  next()
}

module.exports = authMiddleware
