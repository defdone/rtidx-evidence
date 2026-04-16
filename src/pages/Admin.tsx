import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { PlusIcon, EditIcon, TrashIcon, ShieldIcon, BuildingIcon, CoinsIcon } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { useWallet } from '../context/WalletContext';
import { properties } from '../utils/mockData';

export default function Admin() {
  const { isConnected, isAdmin } = useWallet();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('properties');
  
  const tabs = [
    {
      id: 'properties',
      label: 'Properties',
      icon: <BuildingIcon size={16} />
    },
    {
      id: 'contracts',
      label: 'Contracts',
      icon: <CoinsIcon size={16} />
    }
  ];

  // Mock contract deployments
  const contractDeployments = [
    {
      id: 1,
      name: 'Luxury Downtown Apartment',
      address: '0x1234...5678',
      date: '2023-06-10',
      status: 'Active'
    },
    {
      id: 2,
      name: 'Beachfront Villa',
      address: '0xabcd...efgh',
      date: '2023-05-15',
      status: 'Active'
    },
    {
      id: 3,
      name: 'Modern Office Building',
      address: '0x7890...1234',
      date: '2023-04-22',
      status: 'Active'
    },
    {
      id: 4,
      name: 'Urban Retail Space',
      address: '0xefgh...ijkl',
      date: '2023-03-05',
      status: 'Active'
    },
    {
      id: 5,
      name: 'Historic Brownstone',
      address: '0x2468...1357',
      date: '2023-02-18',
      status: 'Active'
    }
  ];

  if (!isConnected || !isAdmin) {
    return (
      <div className="min-h-screen w-full flex items-center justify-center px-4">
        <div className="text-center max-w-md w-full p-10 rounded-2xl border border-void-700 bg-void-800/80">
          <div className="w-16 h-16 rounded-2xl bg-accent-muted border border-accent/20 flex items-center justify-center mx-auto mb-6">
            <ShieldIcon size={32} className="text-accent" />
          </div>
          <h2 className="font-display text-2xl font-semibold text-cream-100 mb-3">
            Admin access required
          </h2>
          <p className="text-cream-400 mb-8">
            You need admin privileges to access this dashboard.
          </p>
          <Button onClick={() => navigate('/')}>Back to Home</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen w-full">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14 lg:py-20">
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.5 }}>
          <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 mb-10">
            <div>
              <h1 className="font-display text-3xl md:text-4xl font-bold text-cream-100 mb-2">
                Admin Dashboard
              </h1>
              <p className="text-cream-400">Manage properties, contracts, and settings</p>
            </div>
            <Button icon={<PlusIcon size={18} />}>Add property</Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
            {[
              { icon: BuildingIcon, label: 'Total properties', value: properties.length },
              { icon: CoinsIcon, label: 'Active contracts', value: contractDeployments.length, accent: true },
              { label: 'Total sales', value: '5.67 ETH', green: true },
            ].map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1 }}
                className="p-6 rounded-2xl border border-void-700 bg-void-800/60"
              >
                <div className="flex items-center gap-2 text-cream-400 text-sm mb-2">
                  {stat.icon && <stat.icon size={16} />}
                  {stat.label}
                </div>
                <div className={`font-display text-2xl font-bold ${stat.accent ? 'text-accent' : stat.green ? 'text-emerald-400' : 'text-cream-100'}`}>
                  {stat.value}
                </div>
              </motion.div>
            ))}
          </div>

          <div className="rounded-2xl border border-void-700 bg-void-800/40 overflow-hidden">
            <nav className="flex border-b border-void-700">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-6 py-4 flex items-center gap-2 text-sm font-medium transition-colors ${
                    activeTab === tab.id ? 'border-b-2 border-accent text-accent bg-accent-muted/30' : 'text-cream-400 hover:text-cream-100'
                  }`}
                >
                  {tab.icon}
                  {tab.label}
                </button>
              ))}
            </nav>
            <div className="p-6">
              {activeTab === 'properties' && (
                <div>
                  <h3 className="font-display text-lg font-semibold text-cream-100 mb-6">Manage properties</h3>
                  <div className="overflow-x-auto rounded-xl border border-void-700">
                    <table className="min-w-full">
                      <thead>
                        <tr className="border-b border-void-700">
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Property</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Location</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Status</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Price</th>
                          <th className="px-6 py-3 text-right text-xs font-medium text-cream-400 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-void-700">
                        {properties.map((p) => (
                          <tr key={p.id} className="hover:bg-void-700/30 transition-colors">
                            <td className="px-6 py-4">
                              <div className="flex items-center gap-3">
                                <div className="h-10 w-10 rounded-lg overflow-hidden flex-shrink-0">
                                  <img src={p.imageUrl} alt={p.title} className="h-full w-full object-cover" />
                                </div>
                                <span className="font-medium text-cream-100">{p.title}</span>
                              </div>
                            </td>
                            <td className="px-6 py-4 text-cream-400">{p.location}</td>
                            <td className="px-6 py-4">
                              <Badge color={p.status === 'Available' ? 'green' : p.status === 'Sold Out' ? 'red' : 'yellow'}>{p.status}</Badge>
                            </td>
                            <td className="px-6 py-4 text-accent">{p.tokenPrice} ETH</td>
                            <td className="px-6 py-4 text-right">
                              <div className="flex justify-end gap-2">
                                <Button variant="outline" size="sm" icon={<EditIcon size={14} />}>Edit</Button>
                                <Button variant="danger" size="sm" icon={<TrashIcon size={14} />}>Delete</Button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
              {activeTab === 'contracts' && (
                <div>
                  <h3 className="font-display text-lg font-semibold text-cream-100 mb-6">Contract deployments</h3>
                  <div className="overflow-x-auto rounded-xl border border-void-700">
                    <table className="min-w-full">
                      <thead>
                        <tr className="border-b border-void-700">
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Property</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Contract</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Date</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Status</th>
                          <th className="px-6 py-3 text-right text-xs font-medium text-cream-400 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-void-700">
                        {contractDeployments.map((c) => (
                          <tr key={c.id} className="hover:bg-void-700/30 transition-colors">
                            <td className="px-6 py-4 text-cream-100">{c.name}</td>
                            <td className="px-6 py-4 text-accent font-mono text-sm">{c.address}</td>
                            <td className="px-6 py-4 text-cream-400">{c.date}</td>
                            <td className="px-6 py-4"><Badge color="green">{c.status}</Badge></td>
                            <td className="px-6 py-4 text-right">
                              <Button variant="outline" size="sm">View on Etherscan</Button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
