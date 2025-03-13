#include "CacheManager.h"
#include <math.h>

CacheManager::CacheManager(Memory *memory, Cache *cache){
    // TODO: implement your constructor here
    // TODO: set tag_bits accord to your design.
    // Hint: you can access cache size by cache->get_size();
    // Hint: you need to call cache->set_block_size();
    this->memory = memory;
    this->cache = cache;
    size = cache->get_size();
    cache->set_block_size(4);
    tag_bits = 30;
    counts = 0;
};

CacheManager::~CacheManager(){

};

std::pair<unsigned, unsigned> CacheManager::directed_map(unsigned int addr){
    // map addr by directed-map method
    unsigned int index_bit = int(log2(cache->get_len()));
    unsigned int index = (addr >> 2) % cache->get_len(); 
    unsigned int tag = addr >> index_bit >> 2;
    return {index, tag};
}

unsigned int CacheManager::fully_associative(unsigned int addr){
    // map addr by fully_associative method
    counts %= 256; 
    unsigned int tag = addr >> 2;
    return tag;
}

unsigned int* CacheManager::find(unsigned int addr){
    // TODO:: implement function determined addr is in cache or not
    // if addr is in cache, return target pointer, otherwise return nullptr.
    // you shouldn't access memory in this function.
    auto tag = fully_associative(addr);
    for(int i = 0; i < 256; i++){
        if((*cache)[i].tag == tag)
            return &((*cache)[i][0]);
    }
    return nullptr;
}

unsigned int CacheManager::read(unsigned int addr){
    // TODO:: implement replacement policy and return value 
    unsigned int* value_ptr = find(addr);
    if(value_ptr != nullptr)
        return *value_ptr;
    else{
        // not in cache
        auto tag = fully_associative(addr);
        (*cache)[counts].tag = tag;
        return (*cache)[counts++][0] = memory->read(addr);
    }
};

void CacheManager::write(unsigned int addr, unsigned value){
    // TODO:: write value to addr
    auto tag = fully_associative(addr);
    bool detect = false;
    for(int i = 0; i < 256; i++){
        if((*cache)[i].tag == tag){
            (*cache)[i][0] = value;
            counts++;
            detect = true;
            break;
        }
    }
    if(!detect){
        (*cache)[counts].tag = tag;
        (*cache)[counts][0] = value;
        counts++;
    }
    memory->write(addr, value);
};

