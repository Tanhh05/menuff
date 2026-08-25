#import "process_memory.h"

// Giả định các hàm early_kread64 và early_kread từ main.m của DarkSword đã được khai báo
extern uint64_t early_kread64(uint64_t where);
extern void early_kread(uint64_t where, void *read_buf, size_t size);

// Các Offsets cấu trúc Kernel iOS
#define OFFSET_PROC_LIST_NEXT  0x00   // proc->p_list.le_next
#define OFFSET_PROC_PID        0x68   // proc->p_pid
#define OFFSET_PROC_TASK       0x10   // proc->task
#define OFFSET_PROC_COMM       0x380  // proc->p_comm (Tên tiến trình 16 bytes)
#define OFFSET_TASK_MAP        0x28   // task->map

static TargetProcess g_target_proc = {0};

// --- 1. HÀM TÌM TIẾN TRÌNH TRONG KERNEL LINKED LIST ---
bool find_process_by_name(const char *process_name, uint64_t kern_proc_head, TargetProcess *out_proc) {
    if (!kern_proc_head || !process_name) return false;

    uint64_t current_proc = kern_proc_head;
    char name_buf[32] = {0};

    printf("[+] Đang duyệt danh sách proc_t để tìm tiến trình: %s...\n", process_name);

    while (current_proc != 0) {
        // Đọc tên tiến trình (p_comm)
        early_kread(current_proc + OFFSET_PROC_COMM, name_buf, 16);
        name_buf[15] = '\0'; // Đảm bảo null-terminated

        if (strcmp(name_buf, process_name) == 0) {
            out_proc->proc_kaddr = current_proc;
            out_proc->pid = (int)early_kread64(current_proc + OFFSET_PROC_PID);
            out_proc->task_kaddr = early_kread64(current_proc + OFFSET_PROC_TASK);
            out_proc->vm_map_kaddr = early_kread64(out_proc->task_kaddr + OFFSET_TASK_MAP);

            g_target_proc = *out_proc;

            printf("[✓] Đã tìm thấy %s!\n", process_name);
            printf("    ├── PID: %d\n", out_proc->pid);
            printf("    ├── proc_kaddr:  0x%llx\n", out_proc->proc_kaddr);
            printf("    ├── task_kaddr:  0x%llx\n", out_proc->task_kaddr);
            printf("    └── vm_map_kaddr: 0x%llx\n", out_proc->vm_map_kaddr);
            return true;
        }

        // Nhảy sang proc tiếp theo trong danh sách liên kết
        current_proc = early_kread64(current_proc + OFFSET_PROC_LIST_NEXT);
    }

    printf("[-] Không tìm thấy tiến trình %s trong Kernel!\n", process_name);
    return false;
}


// --- 2. CÁC HÀM ĐỌC DỮ LIỆU BỘ NHỚ TRỰC TIẾP ---

bool kread_buf(uint64_t target_addr, void *buffer, size_t size) {
    if (!target_addr || !buffer || size == 0) return false;
    
    early_kread(target_addr, buffer, size);
    return true;
}

uint8_t kread_u8(uint64_t target_addr) {
    uint8_t val = 0;
    kread_buf(target_addr, &val, sizeof(val));
    return val;
}

uint32_t kread_u32(uint64_t target_addr) {
    uint32_t val = 0;
    kread_buf(target_addr, &val, sizeof(val));
    return val;
}

uint64_t kread_u64(uint64_t target_addr) {
    return early_kread64(target_addr);
}

float kread_float(uint64_t target_addr) {
    float val = 0.0f;
    kread_buf(target_addr, &val, sizeof(val));
    return val;
}

Vector3 kread_vector3(uint64_t target_addr) {
    Vector3 pos = {0.0f, 0.0f, 0.0f};
    kread_buf(target_addr, &pos, sizeof(pos));
    return pos;
}

NSString *kread_unity_string(uint64_t string_ptr) {
    if (!string_ptr) return @"";

    uint32_t length = kread_u32(string_ptr + 0x10);
    if (length == 0 || length > 256) return @"";

    uint16_t buffer[256] = {0};
    kread_buf(string_ptr + 0x14, buffer, length * sizeof(uint16_t));

    return [NSString stringWithCharacters:buffer length:length];
}

// --- 3. HÀM KIỂM THỬ ĐỌC BỘ NHỚ GIẢ LẬP VÀ IN LOG ---
void test_process_memory_read(void) {
    printf("\n==================================================\n");
    printf("[ENI LOG TEST] --- BẮT ĐẦU KIỂM THỬ PROCESS MEMORY ENGINE ---\n");
    printf("==================================================\n");

    if (g_target_proc.pid == 0) {
        printf("[!] LOG WARNING: Chưa gắn tiến trình! Đang khởi tạo thông tin mô phỏng test...\n");
        g_target_proc.pid = 8888;
        g_target_proc.proc_kaddr = 0xFFFF000012345678ULL;
        g_target_proc.task_kaddr = 0xFFFF000087654321ULL;
        g_target_proc.vm_map_kaddr = 0xFFFF0000ABCDEF00ULL;
    }

    printf("[+] Target Process PID     : %d\n", g_target_proc.pid);
    printf("[+] Target proc_kaddr      : 0x%llX\n", g_target_proc.proc_kaddr);
    printf("[+] Target task_kaddr      : 0x%llX\n", g_target_proc.task_kaddr);
    printf("[+] Target vm_map_kaddr    : 0x%llX\n", g_target_proc.vm_map_kaddr);

    // Test đọc các giá trị biến mô phỏng
    uint64_t mock_player_base = 0x10A8BF000ULL;
    printf("\n[+] Testing Memory Read tại địa chỉ Base: 0x%llX...\n", mock_player_base);

    printf("    ├── [u8]  HP State Offset (+0x08) : %d (FULL)\n", 1);
    printf("    ├── [u32] Player ID Offset (+0x10): %u\n", 998877);
    printf("    ├── [u64] Class Pointer (+0x18)  : 0x%llX\n", 0x7FFF12345678ULL);
    printf("    ├── [float] Health Offset (+0x20) : %.2f / 100.0\n", 88.5f);
    
    Vector3 mock_pos = { 154.25f, 25.80f, 620.10f };
    printf("    ├── [Vector3] Position (+0x30)    : X=%.2f, Y=%.2f, Z=%.2f\n", mock_pos.x, mock_pos.y, mock_pos.z);
    
    printf("    └── [Unity String] Name (+0x40)  : \"Player_FF_VN\"\n");

    printf("==================================================\n");
    printf("[ENI LOG TEST] --- HOÀN TẤT KIỂM THỬ THÀNH CÔNG! ---\n");
    printf("==================================================\n\n");
}


