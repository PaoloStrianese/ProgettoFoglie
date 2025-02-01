import numpy as np
import pandas as pd
import cv2
from PIL import Image

def image_to_excel_rgb(image_path, excel_path):
    # Carica l'immagine
    img = Image.open(image_path)
    img = np.array(img) / 255.0  # Normalizza i valori tra 0 e 1

    # Gestisci immagini con più di 3 canali (RGBA)
    if img.shape[-1] > 3:
        img = img[:, :, :3]  # Tieni solo i primi 3 canali (R, G, B)
    
    # Estrai i canali RGB
    R = img[:, :, 0].flatten()
    G = img[:, :, 1].flatten()
    B = img[:, :, 2].flatten()
    
    # Crea un DataFrame con i canali RGB
    df = pd.DataFrame({'R': R, 'G': G, 'B': B})
    
    # Salva il DataFrame in un file Excel
    df.to_excel(excel_path, index=False)
    print(f"Excel salvato in: {excel_path}")

# Specifica il percorso dell'immagine e del file Excel
image_path = "C:/Users/Utente/git/ProgettoFoglie/dataset/leaf_mosaic.png"
excel_path = "C:/Users/Utente/git/ProgettoFoglie/dataset/leaf_mosaic.xlsx"

# Genera l'Excel
image_to_excel_rgb(image_path, excel_path)