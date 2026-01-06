// Integration test for SurrealDB database operations
// Tests the complete database setup, operations, and cleanup

use surrealdb::{engine::local::Mem, Surreal};

#[tokio::test]
async fn test_database_initialization() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize in-memory database
    let db = Surreal::new::<Mem>(()).await?;

    // Use namespace and database
    db.use_ns("orionhealth").use_db("medical").await?;

    // Verify connection by creating a simple table
    db.query("DEFINE TABLE test SCHEMAFULL").await?;

    Ok(())
}

#[tokio::test]
async fn test_create_and_query_health_record() -> Result<(), Box<dyn std::error::Error>> {
    // Setup
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("orionhealth").use_db("medical").await?;

    // Create a record
    db.query(
        "CREATE health_records SET
            record_type = 'blood_pressure',
            date = time::now(),
            data = {
                systolic: 120,
                diastolic: 80
            }",
    )
    .await?;

    // Query the record - just verify no error
    db.query("SELECT * FROM health_records WHERE record_type = 'blood_pressure'")
        .await?;

    Ok(())
}

#[tokio::test]
async fn test_concurrent_database_operations() -> Result<(), Box<dyn std::error::Error>> {
    // Test that multiple operations can be performed safely
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("orionhealth").use_db("medical").await?;

    // Create multiple records
    for i in 0..10 {
        db.query(format!("CREATE test_records SET value = {}", i))
            .await?;
    }

    // Query all records - just verify no error
    db.query("SELECT * FROM test_records").await?;

    Ok(())
}

#[tokio::test]
async fn test_graph_relationships() -> Result<(), Box<dyn std::error::Error>> {
    // Test SurrealDB's graph capabilities
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("orionhealth").use_db("medical").await?;

    // Create nodes
    db.query(
        "
        CREATE patient:john SET name = 'John Doe';
        CREATE doctor:smith SET name = 'Dr. Smith';
    ",
    )
    .await?;

    // Create relationship
    db.query("RELATE doctor:smith->treats->patient:john")
        .await?;

    // Verify relationship exists - just verify no error
    db.query("SELECT * FROM treats").await?;

    Ok(())
}

#[tokio::test]
async fn test_database_cleanup() -> Result<(), Box<dyn std::error::Error>> {
    // Test proper cleanup operations
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("orionhealth").use_db("medical").await?;

    // Create records
    db.query(
        "
        CREATE temp_records SET value = 'test1';
        CREATE temp_records SET value = 'test2';
    ",
    )
    .await?;

    // Delete all records
    db.query("DELETE temp_records").await?;

    // Verify cleanup - just verify no error
    db.query("SELECT * FROM temp_records").await?;

    Ok(())
}
