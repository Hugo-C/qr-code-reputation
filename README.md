<h1 align="center">QR code reputation</h1>
<p align="center">
    <img width="150" src="/assets/icon/icon.png" alt="App icon"><br>
    Analyze QR code via VirusTotal API.
</p>


## Features

- Bring your own API key (BYOAK)
- "Minimalist" UI
- Quick access to the VirusTotal report page 

## Getting Started

You will first need to register your VirusTotal API key inside the app.  
> Need an API key ? Get one for free by registering in VirusTotal. Head over [here](https://www.virustotal.com/gui/my-apikey).

1. The first time you launch the app, you will have to scan your VirusTotal API key displayed as a QR code.  
   You can use Google Chrome to generate a QR code, just go to a website then click on share in the address bar, the value can then be modified:  
   <p align="center">
    <img src="readme_pictures/chrome_qr_code.PNG" alt="chrome tooltip to generate QR code">
   </p>
2. Scan a suspect QR code  
   <p align="center">
    <img src="/readme_pictures/scan_qr_code.PNG" alt="App icon">
   </p>
3. If VirusTotal already seen its URL, the result will appear immediately. If not the app will request a scan and display its result in *around* a minute.  
   <p align="center">
    <img src="/readme_pictures/scan_result.PNG" alt="scan result as displayed by the app">
   </p>   
4. The bottom left button allows to be redirected straight to VirusTotal report website.