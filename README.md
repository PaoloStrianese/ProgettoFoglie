# Dataset
## foglie singole
creati due dataset uno con sfondo nero/grigio scuro e uno con sfondo bianco
abbiamo rifatto il dataset perchè il localizzatore aveva performance pessime ma anche con sfondo bianco non cambiava molto

## composizioni
- 5 immagini con 10 foglie diverse per ognuna 
- 10 immagini con 5 foglie diverse per ognuna
- immagini con sfondi colorati
- immagini con dentro oggetti diversi da foglie sia con sfondo bianco che colorato

le immagini sono oltre le 200 contenenti almeno 300 foglie diverse

# Localizzatore
## training con mosaico di bg e piante (pixel-based)
mosaico bg     : preso una regione randomica dello sfondo da ogni immagine per evitare overfitting
mosaico piante : preso regione centrale di tutte le foglie

lista canali colore provati in diverse combinazioni:
- RGB
- HSV
- YCbCr
- LAB
- ExG
- ExR

modelli provati:
- Decision Tree
- knn
- Random Forest

## training con tutti i pixel di sfondo e pixel di foglie di tutte le 100 immagini (pixel-based)
si sono presi tutti i pixel estraendo i vari canali e etichettandoli in base a se sono bg o foglia

lista canali colore provati in diverse combinazioni:
- RGB
- HSV
- YCbCr
- LAB
- ExG
- ExR

modelli provati:
- Decision Tree
- knn
- Random Forest
  
## training con regioni nxn con estrazione anche texture oltre al colore da bg sia da foglie (region-based)
estratti le medie e variazioni di regioni, eseguito sui mosaic
non abbiamo provato molto in questa tipologia perchè le performance erano bassisime e molto dispendiose a livello di tempo

lista canali colore provati in diverse combinazioni:
- RGB
- HSV
- YCbCr
- LAB
- ExG
- ExR

modelli provati:
- Decision Tree
- knn
- Random Forest

## canny sobel prewitt roberts (no training)
volevamo farlo per fare la detection di oggetti sconosciuti facendo la differrenza con la maschera estratta con uno dei metodi precendenti 

fa una combinazione tra canny sobel prewitt e roberts per l'edge detection, poi con morfologia matematica chiudiamo i bordi, rimuoviamo rumore e filliamo i buchi
è quello che ha funzionato meglio ma non abbiamo allenato nessun localizzatore

# Classificatore
le performance risultano pessime intorno al 25%-35%

paper da cui abbiamo preso alcune features: 

[computer-aided interpretable features for leaf image classification](https://arxiv.org/pdf/2106.08077)


modelli provati:
- Decision Tree
- knn
- Random Forest


features utilizzate (normalizzate) in vari combinazioni:
- LBP
- GLCM
- Color
- Lacunarity
- HuMoments
- PhysiologicalLength
- PhysiologicalWidth
- Area
- Eccentricity
- CentroidCoordinates
- AspectRatio
- Compactness
- Rectangularity
- NarrowFactor
- PerimeterDiameterRatio
- Fourier
- Perimeter
- Circularity