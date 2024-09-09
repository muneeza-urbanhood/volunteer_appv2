const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'urbanfoodtesting@gmail.com',
    pass: 'RBFLD16659v!'
  }
});

exports.sendDownloadReceiptEmail = functions.firestore
  .document('downloads/{downloadId}')
  .onCreate((snap, context) => {
    const downloadData = snap.data();
    const email = downloadData.email;
    const fileName = downloadData.fileName;

    const mailOptions = {
      from: 'your-email@gmail.com',
      to: email,
      subject: 'Your Receipt Download Confirmation',
      text: `${downloadData.email}, you have downloaded a donation receipt from ${fileName}`
    };

    return transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
    });
  });
