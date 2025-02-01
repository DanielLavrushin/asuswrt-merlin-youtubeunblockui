/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable no-console */
const ftp = require("basic-ftp");

require("dotenv").config();

async function uploadFiles() {
  const client = new ftp.Client();
  client.ftp.verbose = false;

  try {
    await client.access({
      host: process.env.FTP_ROUTER,
      user: process.env.FTP_USERNAME,
      password: process.env.FTP_PASSWORD,
      port: 21,
      secure: false
    });
    console.log("Ensuring directories exist...");
    await client.ensureDir("/addons/yuui");
    await client.ensureDir("/addons/yuui/assets");
    await client.ensureDir("/scripts");
    await client.ensureDir("/");

    await client.uploadFrom("dist/index.asp", "/addons/yuui/index.asp");
    await client.uploadFrom("dist/app.js", "/addons/yuui/app.js");
    await client.uploadFromDir("dist/assets", "/addons/yuui/assets");
    await client.uploadFrom("dist/yuui", "/scripts/yuui");

    await client.send("SITE CHMOD 755 /scripts/yuui");

    console.log("Files uploaded successfully");
  } catch (err) {
    console.error("Error uploading files:", err);
  } finally {
    client.close();
  }
}

uploadFiles();
