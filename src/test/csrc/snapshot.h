#ifndef SNAPSHOT_H
#define SNAPSHOT_H

#ifdef VM_SAVABLE
#include "VXSSimSoC.h"
#include <verilated_save.h>
#include <sys/mman.h>

#define RAMSIZE (3 * 1 * 1024 * 1024 * 1024UL)

class VerilatedSaveMem : public VerilatedSerialize {
  const static long buf_size = RAMSIZE;
  uint8_t *buf;
  long size;

public:
  VerilatedSaveMem() {
    buf = (uint8_t*)mmap(NULL, buf_size, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if (buf == (uint8_t *)MAP_FAILED) {
      printf("Cound not mmap 0x%lx bytes\n", RAMSIZE);
      assert(0);
    }
    size = 0;
  }
  ~VerilatedSaveMem() { }

  void init(const char *filename) {
    size = 0;
    m_filename = filename;
    header();
  }

  void unbuf_write(const void* __restrict datap, size_t size) VL_MT_UNSAFE_ONE {
    memcpy(buf + this->size, datap, size);
    this->size += size;
  }

  void close() { }
  void flush();
  void save();
};

class VerilatedRestoreMem : public VerilatedDeserialize {
  const static long buf_size = RAMSIZE;
  uint8_t *buf;
  long size, buf_ptr;
  // gzFile compressed_mem;

public:
  VerilatedRestoreMem() {
    buf = (uint8_t*)mmap(NULL, buf_size, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if (buf == (uint8_t *)MAP_FAILED) {
      printf("Cound not mmap 0x%lx bytes\n", RAMSIZE);
      assert(0);
    }
    size = 0;
    buf_ptr = 0;
  }
  ~VerilatedRestoreMem() { close(); }

  void open(const char* filenamep) VL_MT_UNSAFE_ONE;
  void open(const std::string& filename) VL_MT_UNSAFE_ONE { open(filename.c_str()); }

  long unbuf_read(uint8_t* dest, long rsize);

  void close() override VL_MT_UNSAFE_ONE;
  void flush() override VL_MT_UNSAFE_ONE {}
  void fill() override VL_MT_UNSAFE_ONE;
};
#endif

#endif
