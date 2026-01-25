# Flutter Hyperswitch

Flutter Hyperswitch is a package designed to facilitate payment operations within Flutter applications, providing seamless integration with payment gateways and offering a variety of customization options.

## Features

- **Initiate Payment Sheet**: Initialize the payment sheet with customizable parameters.
- **Present Payment Sheet**: Display the payment sheet within your Flutter app.

## Getting Started

To use this package in your Flutter project, follow these steps:

### Installation

Add `flutter_hyperswitch` to your `pubspec.yaml` file:

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>yaml</span><!--<button class="copy flex gap-1 items-center"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-sm"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 4C10.8954 4 10 4.89543 10 6H14C14 4.89543 13.1046 4 12 4ZM8.53513 4C9.22675 2.8044 10.5194 2 12 2C13.4806 2 14.7733 2.8044 15.4649 4H17C18.6569 4 20 5.34315 20 7V19C20 20.6569 18.6569 22 17 22H7C5.34315 22 4 20.6569 4 19V7C4 5.34315 5.34315 4 7 4H8.53513ZM8 6H7C6.44772 6 6 6.44772 6 7V19C6 19.5523 6.44772 20 7 20H17C17.5523 20 18 19.5523 18 19V7C18 6.44772 17.5523 6 17 6H16C16 7.10457 15.1046 8 14 8H10C8.89543 8 8 7.10457 8 6Z" fill="currentColor"></path></svg>Copy code</button><button class="flex gap-1 items-center"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-sm"><path fill-rule="evenodd" clip-rule="evenodd" d="M18.0633 5.67375C18.5196 5.98487 18.6374 6.607 18.3262 7.06331L10.8262 18.0633C10.6585 18.3093 10.3898 18.4678 10.0934 18.4956C9.79688 18.5234 9.50345 18.4176 9.29289 18.2071L4.79289 13.7071C4.40237 13.3166 4.40237 12.6834 4.79289 12.2929C5.18342 11.9023 5.81658 11.9023 6.20711 12.2929L9.85368 15.9394L16.6738 5.93664C16.9849 5.48033 17.607 5.36263 18.0633 5.67375Z" fill="currentColor"></path></svg>Copied!</button>--></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">dependencies:
  flutter_hyperswitch: ^version_number</code>
</div></div></pre>

Then, run:

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>dart</span></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">flutter pub get</code>
</div></div></pre>

### Usage

Import the Package

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>dart</span></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">import 'package:flutter_hyperswitch/flutter_hyperswitch.dart';

final _hyper = FlutterHyperswitch();</code>
</div></div></pre>

Initialize the payment sheet with required parameters:

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>dart</span></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">//Set up HyperConfig parameters
_hyper.init(HyperConfig(publishableKey: 'your_publishable_key'));

// Set up the payment parameters
PaymentSheetParams params = PaymentSheetParams(
  clientSecret: 'your_client_secret',
  // Add other required parameters
);

// Initialize the payment sheet
Map&lt;String, dynamic&gt;? result = await _hyper.initPaymentSession(params);</code>
</div></div></pre>

Present the payment sheet within your app:

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>dart</span></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">Map&lt;String, dynamic&gt;? result = await _hyper.presentPaymentSheet();</code></div></div></pre>

## Configuration

You'll need to configure your backend and obtain necessary keys/secrets for successful payment processing. Please refer to our documentation [Node SDK Reference](https://docs.hyperswitch.io/learn-more/sdk-reference/node) for detailed setup instructions.

In the example project, you can also create a simple mock server using the following commands:

<pre><div class="bg-black rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 dark:bg-token-surface-primary px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>bash</span></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-dart">cd server
npm i
npm start</code></div></div></pre>

## Documentation

For detailed usage instructions, examples, and API reference, visit the documentation.

## Issues & Contributions

If you encounter any issues or would like to contribute, feel free to <!-- open an issue or create a pull request in the GitHub repository [link_to_repo]. -->
reach out us [here](https://hyperswitch-io.slack.com/).

<style>
pre {
    background-color: transparent;
}
button {
    all: unset;
    cursor: pointer;
}
button:focus {
  outline: revert;
}
.bg-black {
    background-color: rgba(0,0,0,1);
}
.rounded-md {
    border-radius: 0.375rem;
}
.flex {
    display: flex;
}
.relative {
    position: relative;
}
.justify-between {
    justify-content: space-between;
}
.items-center {
    align-items: center;
}
.text-gray-200 {
    color: rgba(217,217,227,1);
}
.text-xs {
    font-size: .75rem;
    line-height: 1rem;
}
.font-sans {
    font-family: Söhne, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Ubuntu, Cantarell, "Noto Sans", sans-serif, "Helvetica Neue", Arial, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
}
.py-2 {
    padding-bottom: 0.5rem;
    padding-top: 0.5rem;
}
.px-4 {
    padding-left: 1rem;
    padding-right: 1rem;
}
.bg-gray-800 {
    background-color: rgba(52,53,65,1);
}
.rounded-t-md {
    border-top-left-radius: 0.375rem;
    border-top-right-radius: 0.375rem;
}
.p-4 {
    padding: 1rem;
}
.overflow-y-auto {
    overflow-y: auto;
}
</style>
