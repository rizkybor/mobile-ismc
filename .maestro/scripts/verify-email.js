// Tandai email terverifikasi di Auth Emulator (token "owner").
// Maestro menjalankan JS dengan http.* bawaan.
const email = 'maestro.' + STAMP + '@example.com';
const base = 'http://127.0.0.1:9099';
const lookup = http.post(base + '/identitytoolkit.googleapis.com/v1/accounts:lookup', {
  headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: [email] }),
});
const uid = json(lookup.body).users[0].localId;
http.post(base + '/identitytoolkit.googleapis.com/v1/accounts:update', {
  headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
  body: JSON.stringify({ localId: uid, emailVerified: true }),
});
