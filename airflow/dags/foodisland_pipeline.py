from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.databricks.operators.databricks import (
    DatabricksRunNowOperator
)

with DAG(
    dag_id="foodisland_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # lancement manuel
    catchup=False,
    max_active_runs=1,
    tags=["foodisland", "databricks", "dbt"],
) as dag:

    # Exécute le Job Databricks qui lance le pipeline
    bronze_pipeline = DatabricksRunNowOperator(
        task_id="bronze_pipeline",
        databricks_conn_id="databricks_default",
        job_id=1052502654050571  # Remplacer par ton Job ID
    )

    # Lance uniquement les modèles Silver
    dbt_silver = BashOperator(
        task_id="dbt_silver",
        bash_command="""
        cd /opt/airflow/dbt/foodisland_project && \
        dbt run \
            --select 02_silver \
            --profiles-dir /opt/airflow/.dbt
        """
    )

    bronze_pipeline >> dbt_silver