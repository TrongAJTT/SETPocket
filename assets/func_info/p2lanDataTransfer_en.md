# P2Lan Data Transfer
Fast and secure data transfer over LAN between devices on the same WiFi network, supporting file and folder sending/receiving, with various security options and optimized performance.

## [lan, blue] Key Features
- [icon:devices] Multi-device Connection: Automatically detects and connects devices on the same LAN.
- [icon:send] Send & Receive Files/Folders: Supports sending multiple files or entire folders at high speed.
- [icon:security] Encryption Options: Protects data with various encryption modes (None, AES, ...).
- [icon:settings] Customizable Settings: Diverse options for save location, size limits, transfer streams, protocols, notifications, etc.
- [icon:history] History & Batch Management: Tracks progress, manages file transfer batches, easily deletes or clears cache.
- [icon:notifications] Smart Notifications: Receives notifications for pairing requests, file reception, or data transfer completion.

## [play_circle, green] Quick Start Guide
1. Start: Open the P2Lan Data Transfer function on both devices on the same WiFi network.
2. Grant Permissions: Ensure memory, network, and notification access permissions are granted (if required).
3. Network Discovery: The device will automatically scan and display available devices.
4. Pair: Select the device you want to send files to, tap on the device name to pair (if not already paired).
5. Send Files: After successful pairing, select files/folders to send.
6. Handle Send Request: The receiving device will receive a notification and confirm acceptance of the files.
7. Transfer Files: Monitor the file transfer progress in the "Transfers" tab. You can cancel, delete, or open files after transfer completion.

## [settings, indigo] Explanation of Important Settings
- [icon:folder] Download Path: Select the folder to save received files. Can be customized or use default.
- [icon:category] File Organization: By date, by sender, or unclassified.
- By Date: Automatically creates a folder by the date the file was received.
- By Sender: Creates a folder by the name of the sending device.
- Unclassified: Saves all files to a single folder.
- [icon:lock] Encryption Type: Select the data transfer encryption mode (None/AES/...).
- [icon:bolt] Max Chunk Size: Size of data packets transferred (increase to optimize speed on strong networks, decrease if network is weak).
- [icon:layers] Max Concurrent Tasks: Number of parallel transfer streams (increase to transfer multiple files simultaneously, decrease if device is weak).
- [icon:notifications] Enable Notifications: Turn on/off notifications for new events.
- [icon:cloud_upload] Max Receive File Size: Maximum size limit for each received file.
- [icon:cloud_download] Max Total Receive Size: Limit for total received size in a batch.
- [icon:network_wifi] Send Protocol: Select the transfer protocol (TCP/UDP).

## [build, purple] Usage Tips & Optimization
- Use an easy-to-remember device name for quick identification when pairing.
- Use encryption when transferring sensitive data.
- Increase chunk size and number of streams on a strong local network for maximum speed.
- Use the "Clear Cache" feature to free up memory when needed.
- Enable notifications to avoid missing important file reception requests.
- You can send multiple files/folders at once by selecting a send batch.

## [security, orange] Security Notes
- Only pair and transfer files with trusted devices on the same LAN.
- Carefully check device information before confirming file reception.
- Do not share your WiFi network with strangers when using this function.
- Use encryption to protect personal data.

## [help_outline, teal] Common Troubleshooting
- Cannot see other devices: Check WiFi connection, network permissions, disable VPN/network blocking.
- Cannot send/receive files: Check memory access permissions, available storage, or try restarting the application.
- Pairing error: Ensure both devices have the P2Lan function open and are on the same network.

## [info_outline, red] Important Note
- This function only works within the same LAN/WiFi network, not over the Internet.
- Transfer speed depends on the quality of the local network and device configuration.
- Avoid transferring very large files on devices with weak configurations or unstable networks.
