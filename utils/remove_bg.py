import os
import io
from rembg import remove
from PIL import Image, ImageChops

def process_image(image_path, no_bg_path, all_bg_path):
    # Apri l'immagine originale in modalità RGBA
    original = Image.open(image_path).convert("RGBA")
    
    # Leggi l'immagine come bytes e rimuovi lo sfondo con rembg
    with open(image_path, 'rb') as f:
        input_data = f.read()
    result_data = remove(input_data)
    
    # L'immagine restituita da rembg contiene il soggetto con sfondo trasparente
    foreground = Image.open(io.BytesIO(result_data)).convert("RGBA")
    
    # Salva l'immagine senza sfondo nella cartella no_bg
    foreground.save(no_bg_path)
    
    # Estrai il canale alfa, che indica dove è presente il soggetto
    alpha = foreground.split()[3]
    # Crea una maschera binaria: 255 dove c'è soggetto, 0 dove non c'è
    mask_foreground = alpha.point(lambda p: 255 if p > 0 else 0)
    # Inverti la maschera per ottenere il background (255 dove non c'è soggetto)
    mask_background = ImageChops.invert(mask_foreground)
    
    # Usa la maschera background per estrarre le parti di background dall'immagine originale.
    # Si crea un'immagine vuota (completamente trasparente) e si compone il risultato:
    background_only = Image.composite(original, Image.new("RGBA", original.size), mask_background)
    
    # Salva l'immagine del background nella cartella all_bg
    background_only.save(all_bg_path)
    
    print(f"Elaborato: {os.path.basename(image_path)}")

def process_folder(input_folder, output_no_bg_folder, output_all_bg_folder):
    # Crea le cartelle di output se non esistono
    if not os.path.exists(output_no_bg_folder):
        os.makedirs(output_no_bg_folder)
    if not os.path.exists(output_all_bg_folder):
        os.makedirs(output_all_bg_folder)
    
    for filename in os.listdir(input_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            image_path = os.path.join(input_folder, filename)
            base_name = os.path.splitext(filename)[0]
            no_bg_path = os.path.join(output_no_bg_folder, f"{base_name}.png")
            all_bg_path = os.path.join(output_all_bg_folder, f"{base_name}.png")
            process_image(image_path, no_bg_path, all_bg_path)

if __name__ == "__main__":
    # Cartella di input
    input_folder = r"C:\Users\Utente\git\ProgettoFoglie\enhanced_images"
    # Cartelle di output
    output_no_bg_folder = r"no_bg"
    output_all_bg_folder = r"all_bg"
    
    process_folder(input_folder, output_no_bg_folder, output_all_bg_folder)
