import numpy as np
import pandas as pd
from PIL import Image

def image_to_excel(image_path, excel_path):
    # Carica l'immagine
    img = Image.open(image_path)
    img = np.array(img) / 255.0  # Normalizza i valori tra 0 e 1

    # Gestisci immagini con più di 3 canali (RGBA)
    if img.shape[-1] > 3:  # Controlla se c'è il canale alfa
        img = img[:, :, :3]  # Tieni solo i primi 3 canali (R, G, B)
    
    # Riorganizza in formato tabellare
    r, c, ch = img.shape
    reshaped_data = img.reshape((r * c, ch))
    
    # Crea un DataFrame e salva come Excel
    df = pd.DataFrame(reshaped_data, columns=["R", "G", "B"])
    df.to_excel(excel_path, index=False)
    print(f"Excel salvato in: {excel_path}")

# Specifica il percorso dell'immagine e del file Excel
image_path = "C:/Users/Utente/git/ProgettoFoglie/dataset/leaf_mosaic.png"
excel_path = "C:/Users/Utente/git/ProgettoFoglie/dataset/leaf_mosaic.xlsx"

# Genera l'Excel
image_to_excel(image_path, excel_path)
