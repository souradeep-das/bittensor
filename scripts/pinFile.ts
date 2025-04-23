import { readFile } from "fs/promises";
import { basename, join } from "path";
import { PinataSDK } from "pinata";
import path from 'path';
import dotenv from "dotenv";

import { fileURLToPath } from "url";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, "../.env") });

const pinata = new PinataSDK({
  pinataJwt: process.env.PINATA_JWT,
  pinataGateway: process.env.GATEWAY_URL,
});

async function main() {
  try {
    const imageFullPath = join(__dirname, "../img", "dragon.jpg");
    const imageBuffer = await readFile(imageFullPath);

    const imgFile = new File([imageBuffer], basename(imageFullPath), {
      type: "image/jpeg",
    });

    const uploadedImg = await pinata.upload.public.file(imgFile);
    const imageUrl = `https://aquamarine-rear-wildcat-197.mypinata.cloud/ipfs/${uploadedImg.cid.toString()}`;
    console.log("✅ Uploaded Image:", imageUrl);


    const modelFullPath = join(__dirname, "../models", "dragon.glb");
    const modelBuffer = await readFile(modelFullPath);
    const modelFileName = basename(modelFullPath);
    const modelFile = new File([modelBuffer], basename(modelFullPath), {
      type: "model/gltf-binary",
    });

    const uploadedModel = await pinata.upload.public.file(modelFile);
    const modelUrl = `https://aquamarine-rear-wildcat-197.mypinata.cloud/ipfs/${uploadedModel.cid.toString()}?filename=${modelFileName}`;
    console.log("✅ Uploaded Model:", modelUrl);

    const metadata = {
        name: "3d Image",
        description: "This is my image",
        image: imageUrl,
        model: modelUrl,
    }
    console.log(metadata)
    const res = await pinata.upload.public.json(metadata);
    console.log('https://aquamarine-rear-wildcat-197.mypinata.cloud/ipfs/' + res.cid);
  } catch (err) {
    console.error("❌ Upload failed:", err);
  }
}

main();
