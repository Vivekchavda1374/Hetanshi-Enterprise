importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBGxO9g5qWo79TKi1kbSxGZjeY7NJA2ZdA",
    authDomain: "hetanshi-enterprice.firebaseapp.com",
    projectId: "hetanshi-enterprice",
    storageBucket: "hetanshi-enterprice.firebasestorage.app",
    messagingSenderId: "535853790260",
    appId: "1:535853790260:web:67a20a63a75c987ac00661",
    measurementId: "G-CEP300S9TY"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});
