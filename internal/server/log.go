package server

import(
	"fmt"
	"sync"
)
// this is the core data structure
// it has a lock to prevent double access of the same resource overtime
type Log struct{
	mu		sync.Mutex
	records []Record
}
// this is used to initialize the log data structure
func NewLog() *Log{
	return &Log{}
}

// this is the record defined inn Json form
type Record struct{
	Value []byte `json:"value"`
	Offset uint64 `json:"offset"`
}

// We need two functions that just perform reading and writing
 func (c *Log) Append(record Record) (uint64, error){
	c.mu.Lock()
	defer c.mu.Unlock()
	record.Offset = uint64(len(c.records))
	c.records = append(c.records, record)
	return record.Offset, nil
 } 

 func (c *Log) Read(offset uint64) (Record, error){
	c.mu.Lock()
	defer c.mu.Unlock()
	if offset >= uint64(len(c.records)){
		return Record{}, ErrOffsetNotFound
	}
	return c.records[offset], nil
 }

 var ErrOffsetNotFound = fmt.Errorf("Offset not Found")