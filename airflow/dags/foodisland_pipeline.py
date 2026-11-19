from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.databricks.operators.databricks import (
    DatabricksRunNowOperator
)

with DAG(
    dag_id="foodisland_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["foodisland", "databricks", "dbt"],
) as dag:

    # ==========================================================
    # Bronze
    # ==========================================================

    bronze_pipeline = DatabricksRunNowOperator(
        task_id="bronze_pipeline",
        databricks_conn_id="databricks_default",
        job_id=1052502654050571,  # à remplacer
    )

    # ==========================================================
    # Silver
    # ==========================================================

    dbt_silver = BashOperator(
        task_id="dbt_silver",
        bash_command="""
        cd /opt/airflow/dbt/foodisland_project &&

        dbt run \
          --select 02_silver \
          --profiles-dir /opt/airflow/.dbt
        """
    )

    # ==========================================================
    # Tests Silver
    # ==========================================================

    dbt_test_silver = BashOperator(
        task_id="dbt_test_silver",
        bash_command="""
        cd /opt/airflow/dbt/foodisland_project &&

        dbt test \
          --select 02_silver \
          --profiles-dir /opt/airflow/.dbt
        """
    )

    # ==========================================================
    # Gold
    # ==========================================================

    dbt_gold = BashOperator(
        task_id="dbt_gold",
        bash_command="""
        cd /opt/airflow/dbt/foodisland_project &&

        dbt run \
          --select 03_gold \
          --profiles-dir /opt/airflow/.dbt
        """
    )

    # ==========================================================
    # Tests Gold
    # ==========================================================

    dbt_test_gold = BashOperator(
        task_id="dbt_test_gold",
        bash_command="""
        cd /opt/airflow/dbt/foodisland_project &&

        dbt test \
          --select 03_gold \
          --profiles-dir /opt/airflow/.dbt
        """
    )

    # ==========================================================
    # Pipeline
    # ==========================================================

    (
        bronze_pipeline
        >> dbt_silver
        >> dbt_test_silver
        >> dbt_gold
        >> dbt_test_gold
    )



        # ==========================================================
    # Alternative possible avec dbt build
    # ==========================================================
    #
    # dbt build exécute automatiquement :
    #
    #   dbt run
    #   + dbt test
    #
    # Exemple :
    #
    # dbt_build_silver = BashOperator(
    #     task_id="dbt_build_silver",
    #     bash_command="""
    #     cd /opt/airflow/dbt/foodisland_project &&
    #
    #     dbt build \
    #       --select 02_silver \
    #       --profiles-dir /opt/airflow/.dbt
    #     """
    # )
    #
    # dbt_build_gold = BashOperator(
    #     task_id="dbt_build_gold",
    #     bash_command="""
    #     cd /opt/airflow/dbt/foodisland_project &&
    #
    #     dbt build \
    #       --select 03_gold \
    #       --profiles-dir /opt/airflow/.dbt
    #     """
    # )
    #
    # Pipeline simplifié :
    #
    # bronze_pipeline
    #     >> dbt_build_silver
    #     >> dbt_build_gold
    #
    # Pour ce projet on conserve volontairement :
    #
    # bronze_pipeline
    #     >> dbt_silver
    #     >> dbt_test_silver
    #     >> dbt_gold
    #     >> dbt_test_gold
    #
    # afin de séparer clairement :
    # - les transformations
    # - les contrôles qualité
    # et d'avoir une meilleure visibilité dans Airflow.