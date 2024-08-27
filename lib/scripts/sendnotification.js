const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'your-email@gmail.com',
    pass: 'your-email-password'
  }
});

exports.sendDownloadReceiptEmail = functions.firestore
  .document('downloads/{downloadId}')
  .onCreate((snap, context) => {
    const downloadData = snap.data();
    const email = downloadData.email;
    const receiptUrl = downloadData.receiptUrl;

    const mailOptions = {
      from: 'your-email@gmail.com',
      to: email, // Send email to the specific user
      subject: 'Your Receipt Download Confirmation',
      text: `Your receipt has been downloaded successfully. You can access it here: ${receiptUrl}`
    };

    return transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
    });
  });
