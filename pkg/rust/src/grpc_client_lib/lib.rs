mod grpc {
use bytesize::ByteSize;

    pub trait GrpcClient {
        fn get_data(&self, conn: &str) -> String;
    }

    pub struct Client {}

    pub fn new() -> Client {
        return Client {}
    }

    impl GrpcClient for Client {
        fn get_data(&self, conn: &str) -> String {
            format!("Connected to '{}' to get data...{} downloaded", conn, ByteSize::mb(123456789)).to_string()
        }
    }
}



#[cfg(test)]
mod tests {
    use crate::grpc::GrpcClient;
    use super::*;

    #[test]
    fn test_new() {
        let _client = grpc::new();
        assert!(true)
    }

    #[test]
    fn test_get_data() {
        let client = grpc::new();
        let data = client.get_data("AT&T");
        assert_eq!(data, "Connected to 'AT&T' to get data...123.5 TB downloaded");
    }
}