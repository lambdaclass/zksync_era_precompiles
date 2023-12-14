use std::fs::OpenOptions;
use std::io::Write;

fn main() {
    let directory = "gas_reports";
    if !std::path::Path::new(directory).exists() {
        std::fs::create_dir(directory).unwrap();
    }

    let precompiles_report_list: Vec<String> = vec![
        "modexp".to_string(),
        "ecadd".to_string(),
        "ecmul".to_string(),
        "ecpairing".to_string(),
        "p256verify".to_string(),
        "secp256k1verify".to_string(),
        "verifier".to_string(),
        "p256verify_benches_report".to_string(),
    ];
    precompiles_report_list
        .into_iter()
        .for_each(|mut precompile_name| {
            let file_path = format!("{}/{}_report.md", directory, precompile_name);
            precompile_name.push_str("_report.md");
            let mut file = OpenOptions::new()
                .create(true)
                .write(true)
                .truncate(true)
                .open(file_path)
                .unwrap();

            writeln!(file, "| Test case | Gas used |").unwrap();
            writeln!(file, "| --------- | -------- |").unwrap();
        });
}
