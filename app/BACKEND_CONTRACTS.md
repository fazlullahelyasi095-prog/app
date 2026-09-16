# Backend contract inventory

Inspected the existing Express routes, services, Socket.io handlers, React hooks,
and Flutter client before editing. No backend files or database contracts changed.

| Area | Existing contract (HTTP paths relative to /api) |
| --- | --- |
| Auth | POST /auth/register (username,email,password,termsAccepted,privacyAccepted); POST /auth/login returns token/user; GET /auth/profile. JWT Bearer HTTP and auth.token Socket.io handshake. |
| User/feed | GET /user/:id returns user/videos; GET /feed. Existing User, FeedVideo, auth, feed and ad services retained. |
| Social | POST /follow/:userId and GET /follow/status/:userId; existing /likes and /comments services retained. |
| Upload | POST /videos/upload multipart media/caption; POST /user/me/profile-picture multipart profilePicture. Existing upload client retained. |
| Chat | POST /chat/start {userId}; GET /chat/list; GET /chat/:conversationId; POST /chat/send {conversationId,message}; POST /chat/read {conversationId}. Conversation fields are snake_case; messages are normalized camelCase. |
| Chat socket | join; join_chat/leave_chat with scalar conversation ID; receive_message/conversation_updated. HTTP persists messages. |
| Live | GET /live/list; GET /live/:id; POST /live/start {title}; POST /live/end/:id. Server enforces ownership. |
| Live media | POST /live/:id/media-token returns url/token/role. React useWebRTC.js uses LiveKit, as does mobile. |
| Live interactions | join_live/leave_live {liveId}; viewer_count {viewerCount}; send_live_comment {liveId,message}; receive_live_comment; send_live_like {liveId}; receive_live_like {totalLikes}. GET /live-comment/:liveId returns {success,data}. Socket join already updates viewer presence. |
| Gifts | GET /gifts. send_live_gift with liveId/receiverId/giftId/operationKey/idempotencyKey and acknowledgement; server handles live versus PK. Retry in the same room preserves the key. HTTP /live-gift is not substituted for the PK socket flow. |
| Wallet | GET /wallet/me returns coin_balance, cash_balance, pending_cash_balance. Client displays amounts without conversion or balance calculations. |
| Transactions | GET /transactions/me?page=1&pageSize=20 returns data/pagination. |
| Earnings | GET /creator-earnings/:liveId/earnings returns totalGifts/totalCoins/estimatedCash; /history returns name/sender/coins/created_at. Server restricts to live owner. |
| PK | pk_request {receiverId}; pk_accept_request/pk_reject_request scalar request ID; pk_battle_state/pk_started; pk_score_updated; pk_ended/pk_finished. Participants and scores are server-provided. |
| PK WebRTC | pk-webrtc:join acknowledgement determines canPublish. publisher-ready, find-publishers, subscriber-ready, offer/answer, ice-candidate, peer-left, leave mirror usePKWebRTC.js. webrtc:get-config provides STUN/TURN. |
| Notifications | GET /notifications?limit=20&offset=0; POST /notifications/:id/read and /notifications/read-all; notification socket event. |

Sources: server.js, routes/{auth,user,feed,follow,like,comment,video,chat,live,
liveComment,liveLike,liveViewer,liveGift,gifts,wallet,transaction,creatorEarnings,
pkBattle,notifications}.js; middleware/auth.js; services/{WalletService,
TransactionService,CreatorEarningsService,LiveGiftService,PKBattleService}.js;
sockets/{liveSocket,webRTCSocket}.js; React hooks useWebRTC/usePKWebRTC/usePKSocket.

Existing caveats: /live/active-pk/:liveId refers to PKBattleService without an
import. Mobile uses the existing working socket snapshot. No backend fix made.
The returned LiveKit URL must be reachable from Android. No mobile push-token
registration service was found; notifications are in-app, not background push.
Android release signing still uses the existing debug-key configuration.
