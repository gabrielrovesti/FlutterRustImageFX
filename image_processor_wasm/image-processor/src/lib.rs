use wasm_bindgen::prelude::*;
use image::{ImageBuffer, Rgba, DynamicImage};
use base64::{decode, encode};
use std::io::Cursor;

// Quando si usa JavaScript, dobbiamo avere una funzione di panic handler
#[cfg(feature = "console_error_panic_hook")]
pub fn set_panic_hook() {
    console_error_panic_hook::set_once();
}

#[wasm_bindgen]
pub fn initialize() {
    #[cfg(feature = "console_error_panic_hook")]
    set_panic_hook();
}

#[wasm_bindgen]
pub fn apply_grayscale(base64_image: &str) -> Result<String, JsValue> {
    // Decodifica l'immagine da base64
    let decoded = decode(base64_image.split(",").nth(1).unwrap_or(base64_image))
        .map_err(|e| JsValue::from_str(&format!("Errore decodifica base64: {}", e)))?;
    
    // Carica l'immagine
    let img = image::load_from_memory(&decoded)
        .map_err(|e| JsValue::from_str(&format!("Errore caricamento immagine: {}", e)))?;
    
    // Converti in scala di grigi
    let gray_img = img.grayscale();
    
    // Converti in base64
    let mut buffer = Cursor::new(Vec::new());
    gray_img.write_to(&mut buffer, image::ImageOutputFormat::Png)
        .map_err(|e| JsValue::from_str(&format!("Errore scrittura immagine: {}", e)))?;
    
    let encoded = encode(&buffer.into_inner());
    Ok(format!("data:image/png;base64,{}", encoded))
}

#[wasm_bindgen]
pub fn apply_blur(base64_image: &str, sigma: f32) -> Result<String, JsValue> {
    // Decodifica l'immagine da base64
    let decoded = decode(base64_image.split(",").nth(1).unwrap_or(base64_image))
        .map_err(|e| JsValue::from_str(&format!("Errore decodifica base64: {}", e)))?;
    
    // Carica l'immagine
    let img = image::load_from_memory(&decoded)
        .map_err(|e| JsValue::from_str(&format!("Errore caricamento immagine: {}", e)))?;
    
    // Applica il blur
    let blurred_img = img.blur(sigma);
    
    // Converti in base64
    let mut buffer = Cursor::new(Vec::new());
    blurred_img.write_to(&mut buffer, image::ImageOutputFormat::Png)
        .map_err(|e| JsValue::from_str(&format!("Errore scrittura immagine: {}", e)))?;
    
    let encoded = encode(&buffer.into_inner());
    Ok(format!("data:image/png;base64,{}", encoded))
}

#[wasm_bindgen]
pub fn apply_edge_detection(base64_image: &str) -> Result<String, JsValue> {
    // Decodifica l'immagine da base64
    let decoded = decode(base64_image.split(",").nth(1).unwrap_or(base64_image))
        .map_err(|e| JsValue::from_str(&format!("Errore decodifica base64: {}", e)))?;
    
    // Carica l'immagine
    let img = image::load_from_memory(&decoded)
        .map_err(|e| JsValue::from_str(&format!("Errore caricamento immagine: {}", e)))?;
    
    // Converti in scala di grigi
    let gray_img = img.grayscale();
    
    // Applica rilevamento dei bordi (filtro Sobel semplificato)
    let width = gray_img.width();
    let height = gray_img.height();
    let luma = gray_img.to_luma8();
    
    let mut edge_image = ImageBuffer::new(width, height);
    
    for y in 1..height-1 {
        for x in 1..width-1 {
            let gx = 
                -1i32 * luma.get_pixel(x-1, y-1).0[0] as i32 + 
                 0i32 * luma.get_pixel(x, y-1).0[0] as i32 + 
                 1i32 * luma.get_pixel(x+1, y-1).0[0] as i32 + 
                -2i32 * luma.get_pixel(x-1, y).0[0] as i32 + 
                 0i32 * luma.get_pixel(x, y).0[0] as i32 + 
                 2i32 * luma.get_pixel(x+1, y).0[0] as i32 + 
                -1i32 * luma.get_pixel(x-1, y+1).0[0] as i32 + 
                 0i32 * luma.get_pixel(x, y+1).0[0] as i32 + 
                 1i32 * luma.get_pixel(x+1, y+1).0[0] as i32;
                
            let gy = 
                -1i32 * luma.get_pixel(x-1, y-1).0[0] as i32 + 
                -2i32 * luma.get_pixel(x, y-1).0[0] as i32 + 
                -1i32 * luma.get_pixel(x+1, y-1).0[0] as i32 + 
                 0i32 * luma.get_pixel(x-1, y).0[0] as i32 + 
                 0i32 * luma.get_pixel(x, y).0[0] as i32 + 
                 0i32 * luma.get_pixel(x+1, y).0[0] as i32 + 
                 1i32 * luma.get_pixel(x-1, y+1).0[0] as i32 + 
                 2i32 * luma.get_pixel(x, y+1).0[0] as i32 + 
                 1i32 * luma.get_pixel(x+1, y+1).0[0] as i32;
            
            // Calcola il gradiente
            let gradient = ((gx * gx + gy * gy) as f32).sqrt() as u8;
            edge_image.put_pixel(x, y, Rgba([gradient, gradient, gradient, 255]));
        }
    }
    
    // Converti in DynamicImage
    let dynamic_img = DynamicImage::ImageRgba8(edge_image);
    
    // Converti in base64
    let mut buffer = Cursor::new(Vec::new());
    dynamic_img.write_to(&mut buffer, image::ImageOutputFormat::Png)
        .map_err(|e| JsValue::from_str(&format!("Errore scrittura immagine: {}", e)))?;
    
    let encoded = encode(&buffer.into_inner());
    Ok(format!("data:image/png;base64,{}", encoded))
}