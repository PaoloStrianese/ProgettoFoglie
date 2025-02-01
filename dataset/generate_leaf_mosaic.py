import os
import random
import numpy as np
from PIL import Image, ImageFile

def generate_leaf_mosaic(input_folder, output_image, tile_size, grid_size):
    """
    Genera un mosaico di immagini, selezionando tasselli che non contengono trasparenza.
    """
    # Abilita il caricamento di immagini troncate
    ImageFile.LOAD_TRUNCATED_IMAGES = True

    # Trova tutte le immagini nella cartella di input
    image_files = [os.path.join(input_folder, f) for f in os.listdir(input_folder) if f.endswith('.jpg')]
    if not image_files:
        raise ValueError("La cartella non contiene immagini PNG.")

    # Crea una nuova immagine per il mosaico
    mosaic_width = tile_size[0] * grid_size[0]
    mosaic_height = tile_size[1] * grid_size[1]
    mosaic_image = Image.new("RGBA", (mosaic_width, mosaic_height), (0, 0, 0, 0))  # Sfondo trasparente

    total_tiles = grid_size[0] * grid_size[1]  # Numero totale di tasselli nel mosaico
    completed_tiles = 0  # Numero di tasselli completati

    # Funzione per verificare se un tassello è completamente non trasparente
    def is_non_transparent_tile(tile_np):
        # Verifica se esistono pixel con alpha == 0 (trasparenza)
        return np.all(tile_np[:, :, 3] > 0)  # Assicurati che l'alpha sia maggiore di zero per ogni pixel

    # Genera il mosaico
    for row in range(grid_size[1]):
        for col in range(grid_size[0]):
            # Seleziona un'immagine casuale
            img_path = random.choice(image_files)
            with Image.open(img_path) as img:
                img = img.convert("RGBA")  # Assicurati che l'immagine sia in formato RGBA
                img_np = np.array(img)  # Converte l'immagine in un array NumPy
                
                # Assicurati che l'immagine abbia abbastanza area non trasparente per i tasselli
                img_height, img_width = img_np.shape[:2]

                # Cicla per trovare un tassello valido
                while True:
                    # Seleziona una posizione casuale per il tassello
                    x_offset = random.randint(0, img_width - tile_size[0])
                    y_offset = random.randint(0, img_height - tile_size[1])

                    # Estrai il tassello
                    tile_np = img_np[y_offset:y_offset + tile_size[1], x_offset:x_offset + tile_size[0], :]

                    # Verifica che il tassello non contenga trasparenza
                    if is_non_transparent_tile(tile_np):
                        # Converte il tassello in un'immagine PIL e incolla nel mosaico
                        tile_img = Image.fromarray(tile_np)
                        mosaic_image.paste(tile_img, (col * tile_size[0], row * tile_size[1]), mask=tile_img)
                        completed_tiles += 1
                        break  # Tassello valido trovato, esci dal loop

                # Aggiungi un po' di feedback
                percent_complete = (completed_tiles / total_tiles) * 100
                print(f"Completato: {percent_complete:.2f}% ({completed_tiles}/{total_tiles} tasselli)", end="\r")

    # Salva il mosaico risultante
    mosaic_image.save(output_image)
    print(f"\nMosaico generato e salvato come {output_image}.")

# Parametri
input_folder = "C:\\Users\\Utente\\Downloads\\bg"  # Cartella con immagini trasparenti
output_image = "C:\\Users\\Utente\\Downloads\\bg_mosaic.png"  # Percorso per salvare il mosaico
tile_size = (15, 15)  # Dimensioni di ogni tassello (larghezza, altezza)
grid_size = (40, 40)  # Dimensioni del mosaico (colonne, righe)

# Genera il mosaico
generate_leaf_mosaic(input_folder, output_image, tile_size, grid_size)
