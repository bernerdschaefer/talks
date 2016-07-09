package main

import (
	anet "atman/net"
	"atman/net/ip"
	"bytes"
	"encoding/binary"
	"fmt"
)

func main() {
	dev := anet.DefaultDevice

	fmt.Println("Network device initialized:")
	fmt.Printf("  Mac address: %s\n", dev.MacAddr)
	fmt.Printf("  IP address:  %s\n", dev.IPAddr)

	handleEvents(dev)
}

const (
	NETIF_RSP_NULL = 1
)

func handleEvents(dev *anet.Device) {
	for {
		dev.EventChannel.Wait()

		for dev.Rx.CheckForResponses() {
			var (
				rsp = (*anet.NetifRxResponse)(dev.Rx.NextResponse())
				r   = newPacketReader(dev, rsp)
			)

			processRxPacket(dev, r)
		}

		dev.Rx.PushRequests()
	}
}

func newPacketReader(dev *anet.Device, rsp *anet.NetifRxResponse) io.Reader {
	var (
		buf    = dev.RxBuffers[rsp.ID]
		len    = uint16(rsp.Status)
		packet = buf.Page.Data[rsp.Offset : rsp.Offset+len]
	)

	return bytes.NewReader(packet)
}

func processRxPacket(dev *anet.Device, r io.Reader) error {
	var hdr ip.EthernetHeader

	if err := binary.Read(r, binary.BigEndian, &hdr); err != nil {
		fmt.Printf("rx: unable to read header: %s\n", err)
		return
	}

	fmt.Printf(
		"rx: packet len=%d from=%q to=%q type=0x%04x (%s)\n",
		len,
		hdr.Source,
		hdr.Destination,
		hdr.Type,
		hdr.Type.Name(),
	)
}
