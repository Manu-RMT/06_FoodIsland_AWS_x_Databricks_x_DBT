from _config import *

### Etape pour :
#### La création des schemas
#### Mise en place du schemaLocalisation (on peut le definir à la main ou automatique)
#### Mise en place du schemaEvolutionMode -> en cas de nouvelle colonne, on la récupère dans une colonne "_rescued_data"
 

# Liste des données
categories = {
           "food"     : "Liste des produits",
           "menu" : "Type de menu",
           "order_items"  : "Liste des plats commandés",
           "orders" : "Liste des commandes",
           "restaurant" : "Liste des restaurants",
           "reviews" : "Liste des avis",
           "users" : "Liste des utilisateurs"
           }


# 1. On définit une fonction qui va créer la table pour une entité spécifique
def create_bronze_table(category_name, description):

   raw_source_path = f"{VOLUME_SOURCE_PATH}/{category_name}/"
   bronze_schema_autoload_path = f"{BRONZE_METADATA}schema_tracking_data/{category_name}/"

   @dlt.table(
       name = f"{BRONZE_ZONE}.foodIsland_{category_name}_incremental",
       comment = f"foodIsland {description} incremental"
   )
   def taxi_landing_incremental():
       df = (
           spark.readStream.format("cloudFiles")
               .option("cloudFiles.format", "csv")
               .option("header", "true")
               .option("cloudFiles.includeExistingFiles", "true")
               .option("cloudFiles.schemaLocation", bronze_schema_autoload_path)
               .option("cloudFiles.schemaEvolutionMode", "rescue") 
               .load(raw_source_path)
       )
       for col_name in df.columns:
           new_name = col_name.replace(" ", "_")
           if new_name != col_name:
               df = df.withColumnRenamed(col_name, new_name)
       return df

# 2. On appelle cette fonction dans la boucle
# ATTENTION DLT : Evite le Late Binding ou Laison Tardive (dernière valeur du dictionnaire)
for categorie, desc in categories.items():
   create_bronze_table(categorie, desc)