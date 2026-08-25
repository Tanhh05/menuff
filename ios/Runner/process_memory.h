#import <Foundation/Foundation.h>
#include <stdint.h>
#include <stdbool.h>

// Vector3 dùng cho tọa độ vị trí 3D trong Unity Engine
typedef struct {
    float x;
    float y;
    float z;
} Vector3;

// Cấu trúc chứa thông tin Process đã tìm thấy
typedef struct {
    int pid;
    uint64_t proc_kaddr;   // Địa chỉ proc_t trong Kernel
    uint64_t task_kaddr;   // Địa chỉ task_t trong Kernel
    uint64_t vm_map_kaddr; // Địa chỉ vm_map trong Kernel
} TargetProcess;

// Hàm khởi tạo & tìm kiếm tiến trình theo tên (VD: "FreeFire")
bool find_process_by_name(const char *process_name, uint64_t kern_proc_head, TargetProcess *out_proc);

// Các hàm đọc bộ nhớ tiện ích từ địa chỉ ảo của Tiến trình mục tiêu
uint8_t  kread_u8(uint64_t target_addr);
uint32_t kread_u32(uint64_t target_addr);
uint64_t kread_u64(uint64_t target_addr);
float    kread_float(uint64_t target_addr);
Vector3  kread_vector3(uint64_t target_addr);

// Đọc mảng byte tùy chỉnh
bool kread_buf(uint64_t target_addr, void *buffer, size_t size);

// Đọc chuỗi UTF-8 / Unity String
NSString *kread_unity_string(uint64_t string_ptr);

// Hàm test kiểm thử đọc bộ nhớ và in log chi tiết
void test_process_memory_read(void);

// Lấy thông tin tiến trình thực tế đã attach
TargetProcess get_target_process_info(void);

// Hàm kích hoạt Kernel Exploit DarkSword
int darksword_exploit_entry(int argc, char* argv[]);



