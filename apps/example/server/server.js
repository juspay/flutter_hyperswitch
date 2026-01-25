const express = require("express");
const app = express();
app.use(express.static("./dist"));
app.use(express.json());

require("dotenv").config({ path: "./.env" });

const hyper = require("@juspay-tech/hyperswitch-node")(
  process.env.HYPERSWITCH_SECRET_KEY
);

app.get("/create-payment-intent", async (req, res) => {
  try {
    var paymentIntent = await hyper.paymentIntents.create({
      amount: 2999,
      currency: "USD",
      profile_id: process.env.HYPERSWITCH_PROFILE_ID,
    });

    // Send publishable key and PaymentIntent details to client
    res.send({
      publishableKey: process.env.HYPERSWITCH_PUBLISHABLE_KEY,
      clientSecret: paymentIntent.client_secret,
    });
  } catch (err) {
    return res.status(400).send({
      error: {
        message: err.message,
      },
    });
  }
});

app.listen(5252, () =>
  console.log(`Node server listening at http://localhost:5252`)
);
