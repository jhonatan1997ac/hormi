/* eslint-disable quotes */
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.getAllUsers = functions.https.onRequest(async (request, response) => {
  try {
    const userRecords = await admin.auth().listUsers();
    const users = userRecords.users.map((user) => ({
      uid: user.uid,
      email: user.email,
    }));

    response.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    response.status(500).send('Internal Server Error');
  }
});
