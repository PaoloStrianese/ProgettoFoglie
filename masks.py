import os
from PIL import Image

def crea_maschere_binare(cartella_input, cartella_output):
    if not os.path.exists(cartella_output):
        os.makedirs(cartella_output)

    for root, dirs, files in os.walk(cartella_input):
        # Percorso relativo rispetto a 'cartella_input'
        relative_path = os.path.relpath(root, cartella_input)
        
        # Cartella di output corrispondente
        output_dir = os.path.join(cartella_output, relative_path)
        os.makedirs(output_dir, exist_ok=True)

        # Processa ogni immagine
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg')):
                input_path = os.path.join(root, file)
                output_filename = f"mask_{os.path.splitext(file)[0]}.png"
                output_path = os.path.join(output_dir, output_filename)

                try:
                    with Image.open(input_path) as img:
                        # Converti in RGBA e usa il canale alfa
                        img_rgba = img.convert("RGBA")
                        alpha = img_rgba.split()[-1]
                        maschera = alpha.point(lambda p: 255 if p > 0 else 0)
                        maschera.save(output_path)
                        print(f"Maschera creata: {output_path}")
                except Exception as e:
                    print(f"Errore con {input_path}: {str(e)}")

if __name__ == "__main__":
    # Percorso assoluto per la cartella di input
    cartella_input = r"C:\Users\Utente\Downloads\output_images\nobg"
    # Cartella di output relativa (verrà creata nella directory corrente)
    cartella_output = "gt"
    
    crea_maschere_binare(cartella_input, cartella_output)