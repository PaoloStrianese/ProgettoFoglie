import os
import requests
from time import sleep


def process_image(api_key, image_path, output_path):
    url = "https://api.withoutbg.com/v1.0/alpha-channel"
    headers = {
        "X-API-Key": api_key
    }
    with open(image_path, "rb") as file:
        files = {"file": file}
        response = requests.post(url, headers=headers, files=files)

    if response.status_code == 200:
        with open(output_path, "wb") as output_file:
            output_file.write(response.content)
        print(f"Image processed successfully: {output_path}")
    else:
        print(f"Error processing {image_path}: {
              response.status_code}, {response.text}")


def process_images_in_folder(api_key, input_folder, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    i = 1
    for filename in os.listdir(input_folder):
        input_path = os.path.join(input_folder, filename)

        # Check if it's a file and has an image extension
        if os.path.isfile(input_path) and filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            name, _ = os.path.splitext(filename)
            output_path = os.path.join(output_folder, f"{name}.png")
            process_image(api_key, input_path, output_path)

        i += 1
        if i == 6:
            sleep(62)


# metti nella lista il numero della cartella pianta che vuoi processare
for i in [1, 7, 8, 9, 10]:
    # withoutbg.com con free hai 50 richieste e basta ho usato tempmail per fare nuovi account e ti da nuova API key
    api_key = "key-Y0V6gYGazymvcLAB"
    input_folder = os.path.join("dataset", f"Pianta {i}")
    output_folder = os.path.join("gt",f"Pianta {i}")
    process_images_in_folder(api_key, input_folder, output_folder)
    sleep(62)
