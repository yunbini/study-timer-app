const { onCall } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

setGlobalOptions({ region: "asia-northeast3", maxInstances: 10 });

admin.initializeApp();

exports.kakaoCustomAuth = onCall(async (request) => {
  const accessToken = request.data.accessToken;

  try {
    const kakaoUser = await axios.get(
      "https://kapi.kakao.com/v2/user/me",
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );

    const kakaoId = kakaoUser.data.id;
    const email =
      kakaoUser.data.kakao_account.email ?? `${kakaoId}@kakao.fake`;

    const customToken = await admin
      .auth()
      .createCustomToken(kakaoId.toString(), {
        provider: "kakao",
        email: email,
      });

    return { customToken };
  } catch (error) {
    console.error("카카오 인증 오류:", error);

    throw new Error("Kakao login failed");
  }
});
