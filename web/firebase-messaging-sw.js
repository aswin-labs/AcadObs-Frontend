importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAeaoOPv1zCjvDEmtShrenXXoKO0RZJF_g",
  authDomain: "acadobs-c32a5.firebaseapp.com",
  projectId: "acadobs-c32a5",
  storageBucket: "acadobs-c32a5.firebasestorage.app",
  messagingSenderId: "999846872581",
  appId: "1:999846872581:web:b801d9d15daccc9156be6c",
});

const messaging = firebase.messaging();